# frozen_string_literal: true

class Components::Messages::FormComponent < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::Routes

  def initialize(session:, message:, from: nil, display_state: {}, job_status: nil)
    @session = session
    @message = message
    @from = from
    @display_state = display_state || {}
    @job_status = job_status
  end

  def view_template
    form(action: session_messages_path(@session), method: "post", enctype: "multipart/form-data", data: { controller: "clear-form message-form" },
      id: "message-form") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      input(type: "hidden", name: "from", value: @from) if @from

      div(data: { controller: "message-form" }) do
        textarea(name: "message[content]", rows: 2, class: "messages-form__content", id: "message_content",
          data: { message_form_target: "messageContent" }) do
          plain @message.content.to_s
        end
      end

      div(class: "messages-form__actions") do
        a(href: history_session_messages_path(@session), id: "open-history", **{ "data-turbo-frame" => "remote_modal" }) { plain "History" }

        select(name: "custom_agent_id", id: "custom_agent_id") do
          option(value: "") { plain "" }
          @session.custom_agents.each do |agent|
            option(value: agent.id) { plain "@#{agent.name}" }
          end
        end

        button(type: "button", onclick: safe("document.getElementById('file_upload').click()"), id: "file_upload_label") { plain "File" }
        input(type: "file", id: "file_upload", name: "file[]", accept: "image/*", multiple: true, class: "messages-form__file-upload",
          onchange: safe("document.getElementById('file_upload_label').innerText = " \
                         "this.files.length > 1 ? this.files.length + ' files' : (this.files[0]?.name || 'File')"))

        button(type: "button", onclick: safe("document.getElementById('camera_upload').click()"), id: "camera_upload_label") { plain "Camera" }
        input(type: "file", id: "camera_upload", name: "camera_file", accept: "image/*", capture: "environment",
          class: "messages-form__file-upload",
          onchange: safe("document.getElementById('camera_upload_label').innerText = " \
                         "this.files[0]?.name || 'Camera'"))

        input(type: "hidden", name: "show_messages", value: @display_state[:show_messages])
        input(type: "hidden", name: "show_events", value: @display_state[:show_events])
        input(type: "hidden", name: "show_rpc_messages", value: @display_state[:show_rpc_messages])

        button(type: "submit") { plain "Send" }
      end
    end
  end
end
