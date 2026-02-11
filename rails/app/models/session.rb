class Session < ApplicationRecord
  has_many :rpc_logs, dependent: :destroy
  has_many :messages, dependent: :destroy

  after_initialize :initialize_internals
  before_validation :create_session, on: :create

  def initialize_internals
    @copilot_session = nil
  end

  def send_prompt(prompt)
    rpc_id = copilot_session.send(prompt)
    rpc_log = rpc_logs.find_by(rpc_id: rpc_id)
    unless rpc_log
      raise "RPC log not found for sent prompt with RPC ID: #{rpc_id}"
    end
    messages.create(
      session_id: id,
      rpc_log: rpc_log,
      direction: :outgoing,
      content: prompt
    )
  end

  def handle(direction, rpc_id, data)
    rpc_log = rpc_logs.create(
      direction: direction,
      rpc_id: rpc_id,
      data: data
    )
    if rpc_log.incoming? && data[:method] == "session.event"
      event = data.dig(:params, :event)
      handle_event(rpc_log, event) if event
    end
    rpc_log
  end

  def handle_event(rpc_log, event)
    type = event[:type]
    return if type != "assistant.message"
    content = event.dig(:data, :content)
    return if content.blank?
    rpc_log.create_message(
      session_id: id,
      direction: :incoming,
      content: content
    )
  end

  def close_after_idle
    wait_until_idle
    close_session
  end

  def wait_until_idle
    Client.wait do |rpc_log|
      yield(rpc_log) if block_given? && rpc_log && rpc_log.session_id == id
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
