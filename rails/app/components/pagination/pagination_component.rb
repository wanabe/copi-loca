# frozen_string_literal: true

module Components
  module Pagination
    class PaginationComponent < Components::Base
      include Phlex::Rails::Helpers::URLFor
      include Phlex::Rails::Helpers::Request

      def initialize(collection:, url_proc: nil, current_page: nil, total_pages: nil, window: 2, frame_target: nil)
        @collection = collection
        @url_proc = url_proc || ->(p) { url_for(params: request.query_parameters.merge(page: p)) }
        @current_page = current_page || collection.current_page
        @total_pages = total_pages || collection.total_pages
        @window = window
        @frame_target = frame_target
      end

      def view_template
        return if @total_pages.nil? || @total_pages <= 1

        # Page numbers with window
        start_page = [1, @current_page - @window].max
        end_page = [@total_pages, @current_page + @window].min

        link_attrs = @frame_target ? { "data-turbo-frame" => @frame_target } : {}

        nav(class: "phlex-pagination pagination") do
          if @current_page == 1
            span(class: "first disabled") { plain "< First " }
          else
            a(href: @url_proc.call(1), **link_attrs) { plain "< First " }
          end

          # Previous
          plain " "
          if @current_page > 1
            a(href: @url_proc.call(@current_page - 1), class: "prev", **link_attrs) { plain "< Prev" }
          else
            span(class: "prev disabled") { plain "< Prev" }
          end
          plain " "

          if start_page > 1
            plain " "
            span(class: "gap") { plain "..." } if start_page > 2
            plain " "
          end

          (start_page..end_page).each do |p|
            plain " "
            if p == @current_page
              span(class: "current") { plain p.to_s }
            else
              a(href: @url_proc.call(p), **link_attrs) { plain p.to_s }
            end
            plain " "
          end

          if end_page < @total_pages
            plain " "
            span(class: "gap") { plain "..." } if end_page < @total_pages - 1
            plain " "
          end

          # Next
          plain " "
          if @current_page < @total_pages
            a(href: @url_proc.call(@current_page + 1), class: "next", **link_attrs) { plain "Next >" }
          else
            span(class: "next disabled") { plain "Next >" }
          end
          plain " "

          if @current_page == @total_pages
            span(class: "last disabled") { plain "Last >" }
          else
            a(href: @url_proc.call(@total_pages), **link_attrs) { plain "Last >" }
          end
        end
      end
    end
  end
end
