class SendPromptJob < ApplicationJob
  queue_as :default

  def perform(session_id, prompt, file_paths = [])
    session = Session.find(session_id)
    if file_paths.present?
      attachments = file_paths.map do |path|
        { type: "file", path: path }
      end
    end
    message = session.send_prompt(prompt, attachments: attachments)
    if message
      broadcast_rpc_log(session, message.rpc_log)
      broadcast_message(session, message)
      session.wait_until_idle do |rpc_log|
        broadcast_rpc_log(session, rpc_log)
        if rpc_log.message
          broadcast_message(session, rpc_log.message)
        end
      end
      # Delete uploaded files after Copilot response is complete
      if file_paths.present?
        file_paths.each do |shared_path|
          if shared_path.start_with?("/shared-tmp/")
            tmp_path = Rails.root.join('tmp', File.basename(shared_path))
            File.delete(tmp_path) if File.exist?(tmp_path)
          end
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
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def broadcast_rpc_log(session, rpc_log)
    rpc_log.broadcast_append_to(
      [ session, :rpc_logs ],
      target: "rpc_logs",
      partial: "rpc_logs/rpc_log",
      locals: { rpc_log: rpc_log }
    )
  end
end
