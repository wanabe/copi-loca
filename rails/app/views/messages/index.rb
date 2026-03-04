# frozen_string_literal: true

module Views
  module Messages
    class Index < Components::Base
      def initialize(messages:, limit: 10, history_mode: false)
        @messages = messages
        @limit = limit
        @history_mode = history_mode
      end

      def view_template
        view_context.content_for(:title, "Messages")

        render Components::Messages::IndexComponent.new(messages: @messages, limit: @limit, history_mode: @history_mode)
      end
    end
  end
end
