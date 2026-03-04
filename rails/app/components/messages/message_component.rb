# frozen_string_literal: true

module Components
  module Messages
    class MessageComponent < Components::Base
      def initialize(message:, history_mode: false)
        @message = message
        @history_mode = history_mode
      end

      def view_template
        div id: "message_#{@message.id}", class: ["message-item", (@message.direction == "incoming" ? "incoming" : "outgoing")],
          data: { controller: "toggle-details", action: "click->toggle-details#toggle" } do
          details do
            summary do
              div(class: "summary-flex-row") do
                span(class: "summary-text") do
                  plain @message.content.to_s.lines.first&.chomp.to_s
                  plain "..." if @message.content.to_s.lines.size > 1
                end

                span(class: "meta") do
                  if @history_mode
                    a(href: "#", data: { "action" => "message-copy#copy", "content" => @message.content.to_s }, tabindex: -1) do
                      strong { plain "Pick" }
                    end
                  end

                  now = Time.zone.now
                  if @message.created_at.to_date == now.to_date
                    span(class: "timestamp-main") { plain @message.created_at.strftime("%H:%M:%S.%L") }
                  else
                    span(class: "timestamp-main") { plain @message.created_at.strftime("%Y-%m-%d %H:%M:%S.%L") }
                  end
                end
              end
            end

            div(class: "content messages-message__content") { plain @message.content.to_s }
            div(class: "timestamp-detail") { plain @message.created_at.strftime("%Y-%m-%d %H:%M:%S.%L") }
          end
        end
      end
    end
  end
end
