# frozen_string_literal: true

module Components
  module RpcMessages
    class IndexComponent < Components::Base
      include Phlex::Rails::Helpers::FormAuthenticityToken

      def initialize(session:, methods:, selected_methods:, selected_message_type:, selected_direction:, rpc_messages:)
        @session = session
        @methods = methods
        @selected_methods = selected_methods
        @selected_message_type = selected_message_type
        @selected_direction = selected_direction
        @rpc_messages = rpc_messages
      end

      def view_template
        h1 { plain "Rpc messages" }

        form(action: session_rpc_messages_path(@session), method: "get") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          div do
            strong { plain "Filter by method:" }
            br
            @methods.each do |method|
              label do
                input(type: "checkbox", name: "methods[]", value: method, checked: @selected_methods.include?(method), id: "method_#{method}")
                plain " "
                plain method
              end
            end
          end

          div do
            strong { plain "Type:" }
            select(name: :message_type) do
              option(value: "") { plain "" }
              RpcMessage.message_types.each_key do |k|
                option(value: k, selected: (k == @selected_message_type)) { plain k.titleize }
              end
            end
          end

          div do
            strong { plain "Direction:" }
            select(name: :direction) do
              option(value: "") { plain "" }
              RpcMessage.directions.each_key do |k|
                option(value: k, selected: (k == @selected_direction)) { plain k.titleize }
              end
            end
          end

          div do
            button(type: "submit") { plain "Show" }
          end
        end

        render Components::RpcMessages::RpcMessagesComponent.new(rpc_messages: @rpc_messages, limit: 10)
        render Components::Pagination::PaginationComponent.new(collection: @rpc_messages)
      end
    end
  end
end
