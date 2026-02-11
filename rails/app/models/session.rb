class Session < ApplicationRecord
  has_many :rpc_logs, dependent: :destroy
  has_many :messages, dependent: :destroy

  before_validation :create_session, on: :create

  def send_prompt(prompt)
    copilot_session.send(prompt)
  end

  def handle(rpc_id, message)
    rpc_log = rpc_logs.create(
      direction: :incoming,
      rpc_id: rpc_id,
      data: message
    )
    return if message[:method] != "session.event"
    event = message.dig(:params, :event)
    return unless event
    type = event[:type]
    return if type != "assistant.message"
    content = event.dig(:data, :content)
    return if content.blank?
    message = messages.create(
      session_id: id,
      rpc_log: rpc_log,
      direction: :incoming,
      content: content
    )
  end

  def close_after_idle
    Client.wait { @copilot_session.idle? }
    close_session
  end

  private
    def create_session
      @copilot_session = Client.create_session(self)
    end

    def copilot_session
      return @copilot_session if @copilot_session
      @copilot_session = Client.resume_session(self)
    end

    def close_session
      return unless @copilot_session
      @copilot_session.destroy
      @copilot_session = nil
    end

    def open
      yield(copilot_session)
    ensure
      close_session
    end

end
