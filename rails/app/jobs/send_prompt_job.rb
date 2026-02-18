class SendPromptJob < ApplicationJob
  WAIT_INTERVAL = 0.1.seconds
  queue_as :default

  def perform(session_id, prompt, file_paths, display_state)
    session = Session.find(session_id)
    if file_paths.present?
      attachments = file_paths.map do |path|
        { type: "file", path: path }
      end
    end
    message = session.send_prompt(prompt, attachments: attachments)

    if message
      wait_until = Time.current
      session.wait_until_idle do |rpc_message|
        if Time.current >= wait_until
          broadcast(session, display_state, :running)
          wait_until = Time.current + WAIT_INTERVAL
        end
      end
      sleep(WAIT_INTERVAL)
      broadcast(session.reload, display_state, :idle)
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

  def broadcast(session, display_state, job_status)
    Turbo::StreamsChannel.broadcast_replace_to(
      [ session, :stream ],
      target: "session-stream",
      partial: "sessions/session",
      locals: {  session: session, display_state: display_state, job_status: job_status }
    )
  end
end
