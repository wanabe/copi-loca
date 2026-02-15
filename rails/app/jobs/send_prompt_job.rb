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

      wait_range = 0.1.seconds
      wait_until = Time.current
      messages = session.messages.last(5)
      rpc_messages = session.rpc_messages.last(5)
      session.wait_until_idle do |rpc_log, rpc_message|
        push_limit(rpc_messages, rpc_message)
        push_limit(messages, rpc_message.message)

        if Time.current >= wait_until
          broadcast(session, rpc_messages, messages)
          wait_until = Time.current + wait_range
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
    Turbo::StreamsChannel.broadcast_replace_to(
      [ session, :rpc_messages ],
      target: "latest_5_rpc_messages",
      partial: "rpc_messages/rpc_messages",
      locals: { rpc_messages: rpc_messages.reverse, limit: 5 }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      [ session, :messages ],
      target: "latest_5_messages",
      partial: "messages/messages",
      locals: { messages: messages.reverse, limit: 5 }
    )
  end
end
