# frozen_string_literal: true
# rbs_inline: enabled

class Components::Paginator < Components::Base
  # @rbs @items: Kaminari::PaginatableArray[untyped]
  # @rbs @params: Hash[untyped, untyped] # TODO: Specify type
  # @rbs @current_page: Integer
  # @rbs @total_pages: Integer
  # @rbs @per_page: Integer
  # @rbs @window: Integer
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
    @window = 2
    @remote = remote
  end

  # @rbs return: void
  def view_template
    nav(role: "navigation", aria: { label: "pager" }) do
      if @current_page > 1
        link_to "<First", page_url(1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
        link_to "<Prev", page_url(@current_page - 1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
      end

      left = [@current_page - @window, 1].max
      right = [@current_page + @window, @total_pages].min

      span(class: "px-2 py-1") { "..." } if left > 1
      (left..right).each do |page|
        if page == @current_page
          span(class: "px-2 py-1 bg-blue-500 text-white rounded") { page }
        else
          link_to page.to_s, page_url(page), class: %w[px-2 py-1 bg-gray-100 rounded hover:bg-gray-200]
        end
      end
      span(class: "px-2 py-1") { "..." } if right < @total_pages

      if @current_page < @total_pages
        link_to "Next>", page_url(@current_page + 1), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
        link_to "Last(#{@total_pages})>", page_url(@total_pages), class: %w[px-2 py-1 bg-gray-200 rounded hover:bg-gray-300]
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
