# frozen_string_literal: true

class Components::Sessions::SessionComponent < Components::Base
  def initialize(session:, display_state:, job_status:)
    @session = session
    @display_state = (display_state || {}).transform_keys(&:to_s)
    @job_status = job_status
  end

  def view_template
    div(id: "session-stream") do
      div(class: "mobile-messages-area") do
        div(class: "toggle-link sessions-session__toggle-link") do
          if @session.current_tokens && @session.token_limit
            div(class: "sessions-session__token-status") do
              span do
                plain "#{@session.current_tokens} / #{@session.token_limit} tokens ("
                plain "#{((@session.current_tokens.to_f / @session.token_limit) * 100).round}%"
                plain ")"
              end
              render Components::Sessions::JobStatusComponent.new(job_status: @job_status)
            end
          end

          span { plain "Messages:" }

          merged = (@display_state || {}).merge("show_messages" => "false")

          if %w[true open].include?(@display_state["show_messages"])
            a(href: session_path(@session, merged), class: "toggle") { plain "Hide" }
            if @display_state["show_messages"] == "open"
              a(href: session_path(@session, @display_state.merge("show_messages" => "true")), class: "toggle") { plain "Close all" }
            else
              a(href: session_path(@session, @display_state.merge("show_messages" => "open")), class: "toggle") { plain "Open all" }
            end
            a(href: session_messages_path(@session), class: "toggle") { plain "More" }
          else
            a(href: session_path(@session, @display_state.merge("show_messages" => "true")), class: "toggle") { plain "Show" }
          end
        end

        if %w[true open].include?(@display_state["show_messages"])
          div(data: { controller: "message-open", "message-open-open-value" => (@display_state["show_messages"] == "open") }) do
            render Components::Messages::MessagesComponent.new(messages: @session.messages.order(id: :desc).limit(5), limit: 5,
              history_mode: false)
          end
        end
      end

      if @display_state["show_events"] == "true"
        div(class: "sessions-session__scroll-x") do
          div(class: "mobile-events-area") do
            div(class: "toggle-link sessions-session__toggle-link") do
              span { plain "Events:" }
              merged = @display_state.merge("show_events" => "false")
              a(href: session_path(@session, merged), class: "toggle") { plain "Hide" }
              a(href: session_events_path(@session), class: "toggle") { plain "More" }
            end
            render Components::Events::EventsComponent.new(events: @session.events.order(id: :desc).limit(5), limit: 5)
          end
        end
      else
        div(class: "toggle-link sessions-session__toggle-link") do
          span { plain "Events:" }
          a(href: session_path(@session, @display_state.merge("show_events" => "true")), class: "toggle") { plain "Show" }
        end
      end

      if @display_state["show_rpc_messages"] == "true"
        div(class: "sessions-session__scroll-x") do
          div(class: "mobile-rpcmessages-area") do
            div(class: "toggle-link sessions-session__toggle-link") do
              span { plain "RPC Messages:" }
              merged = @display_state.merge("show_rpc_messages" => "false")
              a(href: session_path(@session, merged), class: "toggle") { plain "Hide" }
              a(href: session_rpc_messages_path(@session), class: "toggle") { plain "More" }
            end
            render Components::RpcMessages::RpcMessagesComponent.new(rpc_messages: @session.rpc_messages.order(id: :desc).limit(5), limit: 5)
          end
        end
      else
        div(class: "toggle-link sessions-session__toggle-link") do
          span { plain "RPC Messages:" }
          a(href: session_path(@session, @display_state.merge("show_rpc_messages" => "true")), class: "toggle") { plain "Show" }
        end
      end

      div(class: "mobile-destroy-btn") do
        form(action: session_path(@session), method: "post") do
          input(type: "hidden", name: "_method", value: "delete")
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          button(type: "submit", data: { "turbo-confirm" => "Are you sure you want to destroy this session?" }) { plain "Destroy this session" }
        end
      end
    end
  end
end
