# frozen_string_literal: true

module Views
  module RpcMessages
    class Index < Components::Base
      def initialize(session:, methods:, selected_methods:, selected_message_type:, selected_direction:, rpc_messages:)
        @session = session
        @methods = methods
        @selected_methods = selected_methods
        @selected_message_type = selected_message_type
        @selected_direction = selected_direction
        @rpc_messages = rpc_messages
      end

      def view_template
        render Components::RpcMessages::IndexComponent.new(session: @session, methods: @methods, selected_methods: @selected_methods,
          selected_message_type: @selected_message_type, selected_direction: @selected_direction, rpc_messages: @rpc_messages)
      end
    end
  end
end
