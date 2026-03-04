# frozen_string_literal: true

class Views::RpcMessages::Show < Components::Base
  include Phlex::Rails::Helpers::LinkTo

  def initialize(rpc_message:, session:, prev_rpc_message: nil, next_rpc_message: nil)
    @rpc_message = rpc_message
    @session = session
    @prev_rpc_message = prev_rpc_message
    @next_rpc_message = next_rpc_message
  end

  def view_template
    render Components::RpcMessages::RpcMessageComponent.new(rpc_message: @rpc_message, mode: :single)

    div do
      link_to("Prev", session_rpc_message_path(@session, @prev_rpc_message)) if @prev_rpc_message
      link_to("Next", session_rpc_message_path(@session, @next_rpc_message)) if @next_rpc_message
      link_to("Back to rpc messages", session_rpc_messages_path(@session))
    end
  end
end
