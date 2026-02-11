class SendPromptJob < ApplicationJob
  queue_as :default

  def perform(session_id, prompt)
    session = Session.find(session_id)
    message = session.send_prompt(prompt)
    if message
      session.close_after_idle
    end
  end
end
