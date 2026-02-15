class SendPromptJob < ApplicationJob
  queue_as :default

  def perform(session_id, prompt, file_paths)
    session = Session.find(session_id)
    if file_paths.present?
      attachments = file_paths.map do |path|
        { type: "file", path: path }
      end
    end
    message = session.send_prompt(prompt, attachments: attachments)

    if message
      broadcast_job_status(:running)
      broadcast(session, [ message.rpc_message ], [ message ])

      wait_range = 0.1.seconds
      wait_until = Time.current + wait_range
      messages = []
      rpc_messages = []
      session.wait_until_idle do |rpc_log, rpc_message|
        push_limit(rpc_messages, rpc_message)
        push_limit(messages, rpc_message.message)

        if Time.current >= wait_until
          broadcast(session, rpc_messages, messages)
          wait_until = Time.current + wait_range
          rpc_messages.clear
          messages.clear
        end
      end
      broadcast(session, rpc_messages, messages)
      broadcast_job_status(:idle)
    end
  ensure
    # Delete uploaded files after Copilot response is complete
    file_paths.each do |shared_path|
      if shared_path.start_with?("/shared-tmp/")
        tmp_path = Rails.root.join("tmp", File.basename(shared_path))
        File.delete(tmp_path) if File.exist?(tmp_path)
      end
    end
    session&.close_session
  end

  private

  def push_limit(array, obj, limit = 5)
    return unless obj
    array.shift while array.size >= limit
    array << obj
  end

  def broadcast_job_status(status)
    Turbo::StreamsChannel.broadcast_replace_to(
      "job_status",
      target: "job-status",
      partial: "sessions/job_status",
      locals: { job_status: status }
    )
  end

  def broadcast(session, rpc_messages, messages)
    rpc_messages.each do |rpc_message|
      rpc_message.broadcast_prepend_to(
        [ session, :rpc_messages ],
        target: "rpc_messages",
        partial: "rpc_messages/rpc_message",
        locals: { rpc_message: rpc_message }
      )
    end

    messages.each do |message|
      message.broadcast_prepend_to(
        [ session, :messages ],
        target: "messages",
        partial: "messages/message",
        locals: { message: message }
      )
    end
  end
end
