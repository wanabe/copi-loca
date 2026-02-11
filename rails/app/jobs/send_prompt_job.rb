class SendPromptJob < ApplicationJob
  queue_as :default

  def perform(session_id, prompt)
    session = Session.find(session_id)
    message = session.send_prompt(prompt)
    if message
      broadcast_rpc_log(session, message.rpc_log)
      broadcast_message(session, message)
      session.wait_until_idle do |rpc_log|
        broadcast_rpc_log(session, rpc_log)
        if rpc_log.message
          broadcast_message(session, rpc_log.message)
        end
      end
    end
  ensure
    session.close_session if session
  end

  private

  def broadcast_message(session, message)
     message.broadcast_prepend_to(
      [ session, :messages ],
      target: "messages",
      partial: "messages/table",
      locals: { message: message }
    )
  end

  def broadcast_rpc_log(session, rpc_log)
    rpc_log.broadcast_append_to(
      [ session, :rpc_logs ],
      target: "rpc_logs",
      partial: "rpc_logs/table",
      locals: { rpc_log: rpc_log }
    )
  end
end
