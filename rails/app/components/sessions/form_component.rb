# frozen_string_literal: true

class Components::Sessions::FormComponent < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(session:, custom_agents:, models:, tools:)
    @session = session
    @custom_agents = custom_agents
    @models = models
    @tools = tools
  end

  def view_template
    form(action: (@session.persisted? ? session_path(@session) : sessions_path),
      method: (@session.persisted? ? "patch" : "post")) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      if @session.respond_to?(:errors) && @session.errors.any?
        div(class: "sessions-form__errors") do
          count = @session.errors.count
          h2 { plain "#{count} #{count == 1 ? 'error' : 'errors'} prohibited this session from being saved:" }
          ul do
            @session.errors.each do |error|
              li { plain error.full_message.to_s }
            end
          end
        end
      end

      div do
        label(for: "session_model") { plain "Model" }
        br
        select(name: "session[model]", id: "session_model") do
          @models.each do |(label, value)|
            option(value: value, selected: (value == @session.model)) { plain label }
          end
        end
      end

      div(data: { controller: "system-message-mode" }) do
        label { plain "System Message Mode" }
        br
        system_message_modes = Session.system_message_modes.keys.map { |k| [k.to_s.capitalize, k.to_s] }
        select(name: "session[system_message_mode]", id: "session_system_message_mode",
          data: { system_message_mode_target: "mode", action: "change->system-message-mode#toggleMessage" }) do
          system_message_modes.each do |label, val|
            option(value: val, selected: (val.to_s == @session.system_message_mode.to_s)) { plain label.to_s }
          end
        end
        br
        label(for: "system-message") { plain "System Message" }
        br
        textarea(name: "session[system_message]", id: "system-message", rows: 3, data: { system_message_mode_target: "message" }) do
          plain @session.system_message.to_s
        end
      end

      div do
        label { plain "Custom Agents" }
        br
        @custom_agents.each do |ca|
          div do
            id = "session_custom_agent_ids_#{ca.id}"
            input(type: "checkbox", name: "session[custom_agent_ids][]", id: id, value: ca.id,
              checked: @session.custom_agent_ids&.include?(ca.id) || false)
            label(for: id) { plain ca.name.to_s }
          end
        end
      end

      div do
        label { plain "Tools" }
        br
        @tools.each do |t|
          div do
            id = "session_tool_ids_#{t.id}"
            input(type: "checkbox", name: "session[tool_ids][]", id: id, value: t.id, checked: @session.tool_ids&.include?(t.id) || false)
            label(for: id) { plain t.name.to_s }
          end
        end
      end

      div do
        label(for: "session_skill_directory_pattern") { plain "Skill Directory Pattern (Glob pattern)" }
        br
        input(type: "text", name: "session[skill_directory_pattern]", id: "session_skill_directory_pattern",
          value: @session.skill_directory_pattern.to_s)
      end

      div do
        button(type: "submit") { plain(@session.persisted? ? "Update Session" : "Create Session") }
      end
    end
  end
end
