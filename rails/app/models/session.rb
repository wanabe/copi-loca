class Session < ApplicationRecord
  enum :system_message_mode, { default: 0, replace: 1, append: 2 }, prefix: true

  validates :model, presence: true
  has_many :messages, dependent: :delete_all
  has_many :rpc_messages, dependent: :delete_all
  has_many :events, dependent: :delete_all
  has_many :session_custom_agents, dependent: :delete_all
  has_many :custom_agents, through: :session_custom_agents
  has_many :session_tools, dependent: :delete_all
  has_many :tools, through: :session_tools

  after_initialize :initialize_internals
  before_validation :create_session, on: :create

  def initialize_internals
    @copilot_session = nil
  end

  def send_prompt(prompt, attachments: nil)
    rpc_id = copilot_session.send(prompt, attachments: attachments)
    rpc_message = rpc_messages.find_by(rpc_id: rpc_id)
    unless rpc_message
      raise "RPC message not found for sent prompt with RPC ID: #{rpc_id}"
    end
    messages.create!(
      rpc_message: rpc_message,
      direction: :outgoing,
      content: prompt
    )
  end

  def handle(direction, rpc_id, data)
    rpc_messages.create!(
      direction: direction,
      rpc_id: rpc_id,
      method: data[:method],
      params: data[:params]&.except(:sessionId),
      result: data[:result]&.except(:sessionId),
      error: data[:error]
    ).tap(&:handle)
  end

  def close_after_idle
    wait_until_idle
    close_session
  end

  def wait_until_idle
    Client.wait do |rpc_message|
      yield(rpc_message) if block_given? && rpc_message && rpc_message.session_id == id
      @copilot_session.idle?
    end
  end

  def close_session
    return unless @copilot_session
    @copilot_session.destroy
    @copilot_session = nil
  end

  def options
    options = {}
    if system_message_mode_replace?
      options[:systemMessage] = {
        mode: "replace",
        content: system_message
      }
    else
      system_messages = []
      if File.exist?("/app/AGENTS.md")
        agents = File.read("/app/AGENTS.md")
        system_messages << "<attachments path=\"/app/AGENTS.md\">\n#{agents}\n</attachments>\nYou must follow the instructions in the AGENTS.md in any actions you take."
      end
      if system_message_mode_append? && system_message.present?
        system_messages << system_message
      end

      if system_messages.any?
        options[:systemMessage] = {
          mode: "append",
          content: system_messages.join("\n")
        }
      end
    end

    if custom_agents.any?
      options[:customAgents] = custom_agents.map do |agent|
        {
          name: agent.name,
          prompt: agent.prompt || "",
          description: agent.description || ""
        }
      end
    end
    if skill_directory_pattern.present?
      pattern = skill_directory_pattern
      directories = Dir.glob("#{pattern}/SKILL.md").map { File.dirname(_1) }
      options[:skillDirectories] = directories if directories.any?
    end
    if tools.any?
      options[:tools] = tools.map do |tool|
        {
          name: tool.name,
          description: tool.description,
          required: tool.tool_parameters.map(&:name),
          parameters: {
            type: "object",
            properties: tool.tool_parameters.to_h do |arg|
              [
                arg.name,
                {
                  type: "string",
                  description: arg.description
                }
              ]
            end
          },
          handler: tool
        }
      end
    end
    options
  end

  private
    def create_session
      @copilot_session = Client.create_session(self)
    end


    def copilot_session
      return @copilot_session if @copilot_session
      @copilot_session = Client.resume_session(self)
    end
end
