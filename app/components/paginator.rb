# frozen_string_literal: true
# rbs_inline: enabled

class Components::Paginator < Components::Base
  # @rbs @items: Kaminari::PaginatableArray[untyped]
  # @rbs @params: Hash[untyped, untyped] # TODO: Specify type
  # @rbs @current_page: Integer
  # @rbs @total_pages: Integer
  # @rbs @per_page: Integer
  # @rbs @remote: bool

  # @rbs items: Kaminari::PaginatableArray[untyped]
  # @rbs params: Hash[untyped, untyped] # TODO: Specify type
  # @rbs remote: bool
  # @rbs return: void
  def initialize(items:, params: {}, remote: false)
    @items = items
    @params = params
    @current_page = items.current_page
    @total_pages = items.total_pages
    @per_page = items.limit_value
    @remote = remote
  end

  # @rbs return: void
  def view_template
    nav(role: "navigation", aria: { label: "pager" }) do
      unless @current_page == 1
        link_to "<First", page_url(1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
        link_to "<Previous", page_url(@current_page - 1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
      end

      (1..@total_pages).each do |page|
        if page == @current_page
          span(class: "px-2 py-1 bg-blue-500 text-white rounded") { page }
        else
          link_to page.to_s, page_url(page), class: %w[px-2 py-1 bg-gray-100 rounded hover:bg-gray-200]
        end
      end

      unless @current_page == @total_pages
        link_to "Next>", page_url(@current_page + 1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
        link_to "Last>", page_url(@total_pages), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
      end
    end
  end

  private

  # @rbs page: Integer
  # @rbs return: untyped # TODO: Specify type
  def page_url(page)
    url_for(**@params, page: page, per_page: @per_page)
  end
end
