# frozen_string_literal: true

module Components
  module Messages
    class MessagesComponent < Components::Base
      def initialize(messages:, limit: nil, history_mode: false)
        @messages = messages
        @limit = limit
        @history_mode = history_mode
      end

      def view_template
        div(class: "messages-list") do
          @messages.each do |message|
            render Components::Messages::MessageComponent.new(message: message, history_mode: @history_mode)
          end
        end
      end
    end
  end
end
