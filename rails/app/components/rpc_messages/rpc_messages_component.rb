# frozen_string_literal: true

module Components
  module RpcMessages
    class RpcMessagesComponent < Components::Base
      def initialize(rpc_messages:, limit: nil)
        @rpc_messages = rpc_messages
        @limit = limit
      end

      def view_template
        div(class: "rpc-messages-flex-table") do
          div(class: "rpc-messages-flex-row rpc-messages-flex-header") do
            div(class: "rpc-col-id") { plain "ID" }
            div(class: "rpc-col-type") { plain "Type" }
            div(class: "rpc-col-dir") { plain "Direction" }
            div(class: "rpc-col-rpcid") { plain "RPC ID" }
            div(class: "rpc-col-method") { plain "Method" }
            div(class: "rpc-col-params") { plain "Params" }
            div(class: "rpc-col-result") { plain "Result" }
            div(class: "rpc-col-error") { plain "Error" }
          end

          div(class: "rpc-messages-flex-body") do
            @rpc_messages.each do |rpc_message|
              render Components::RpcMessages::RpcMessageComponent.new(rpc_message: rpc_message, mode: :table)
            end
          end
        end
      end
    end
  end
end
