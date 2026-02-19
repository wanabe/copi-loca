class Session < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :rpc_messages, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :session_custom_agents, dependent: :destroy
  has_many :custom_agents, through: :session_custom_agents

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

  private
    def create_session
      @copilot_session = Client.create_session(self)
    end


    def copilot_session
      return @copilot_session if @copilot_session
      @copilot_session = Client.resume_session(self)
    end

    def open
      yield(copilot_session)
    ensure
      close_session
    end
end
