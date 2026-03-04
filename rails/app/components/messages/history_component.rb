# frozen_string_literal: true

class Components::Messages::HistoryComponent < Components::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(messages:)
    @messages = messages
  end

  def view_template
    # Use turbo frame wrapper returned by view_context
    turbo_frame_tag(:remote_modal) do
      dialog(aria_labelledby: "modal_title", data: { controller: "remote-modal message-copy" }) do
        header do
          form(method: "dialog") do
            button(aria_label: "close") { "X" }
          end
        end
        div do
          render Components::Messages::MessagesComponent.new(messages: @messages, limit: 5, history_mode: true)
          div do
            render Components::Pagination::PaginationComponent.new(collection: @messages, frame_target: "remote_modal")
          end
        end
      end
    end
  end
end
