# frozen_string_literal: true

module Components
  module RpcMessages
    class RpcMessageComponent < Components::Base
      def initialize(rpc_message:, mode: nil)
        @rpc_message = rpc_message
        @mode = mode
      end

      def view_template
        div(class: (@mode == :table ? "rpc-messages-flex-row" : "rpc-message")) do
          strong(class: "rpc-label") { plain "ID:" }
          div(class: "rpc-col-id") { a(href: session_rpc_message_path(@rpc_message.session, @rpc_message)) { plain(@rpc_message.id) } }

          strong(class: "rpc-label") { plain "Type:" }
          div(class: "rpc-col-type") { plain @rpc_message.message_type }

          strong(class: "rpc-label") { plain "Direction:" }
          div(class: "rpc-col-dir") { plain @rpc_message.direction }

          strong(class: "rpc-label") { plain "RPC ID:" }
          div(class: "rpc-col-rpcid") { plain @rpc_message.rpc_id }

          strong(class: "rpc-label") { plain "Method:" }
          div(class: "rpc-col-method") { plain @rpc_message.method }

          strong(class: "rpc-label") { plain "Params:" }
          div(class: "rpc-col-params") { plain(@rpc_message.params ? JSON.pretty_generate(@rpc_message.params) : nil) }

          strong(class: "rpc-label") { plain "Result:" }
          div(class: "rpc-col-result") { plain(@rpc_message.result ? JSON.pretty_generate(@rpc_message.result) : nil) }

          strong(class: "rpc-label") { plain "Error:" }
          div(class: "rpc-col-error") { plain(@rpc_message.error ? JSON.pretty_generate(@rpc_message.error) : nil) }
        end
      end
    end
  end
end
