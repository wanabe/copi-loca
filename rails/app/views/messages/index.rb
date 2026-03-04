# frozen_string_literal: true

class Views::Messages::Index < Views::Base
  def initialize(messages:, limit: 10, history_mode: false)
    @messages = messages
    @limit = limit
    @history_mode = history_mode
  end

  def view_template
    content_for(:title, "Messages")
    h1 { plain "Messages" }
    # Render the messages list component
    render Components::Messages::MessagesComponent.new(messages: @messages, limit: @limit, history_mode: @history_mode)

    # Render pagination if applicable
    return unless @messages.respond_to?(:current_page) && @messages.respond_to?(:total_pages) && @messages.total_pages > 1

    div(class: "pagination") do
      # paginate returns HTML safe string; use view_context to call the helper but avoid raw where possible
      div do
        render Components::Pagination::PaginationComponent.new(collection: @messages)
      end
    end
  end
end
