# frozen_string_literal: true

class Components::Breadcrumbs < Components::Base
  def initialize(breadcrumbs:, session: nil)
    @breadcrumbs = breadcrumbs
    @session = session
  end

  def view_template
    nav(aria: { label: "breadcrumb" }, class: %w[flex items-center text-sm text-gray-700 bg-white px-4 py-2 rounded shadow]) do
      ol(class: %w[flex space-x-2]) do
        current_crumb = @breadcrumbs.last
        @breadcrumbs.each do |crumb|
          li(class: %w[flex items-center]) do
            if crumb == current_crumb
              span(class: %w[font-semibold underline text-black-600], aria: { current: "page" }) { crumb.name }
            else
              if crumb.link?
                link_to crumb.name, crumb.path, class: %w[text-blue-500 hover:text-blue-600 transition]
              else
                span(class: %w[text-black-600]) { crumb.name }
              end
              render Components::Breadcrumbs::Separator.new
            end
          end
        end
      end
    end
  end

  class Separator < Phlex::SVG
    def view_template
      svg(
        class: %w[shrink-0 mx-2 size-4 text-muted-foreground],
        xmlns: "http://www.w3.org/2000/svg",
        width: "16", height: "16",
        viewBox: "0 0 16 16",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) do
        path(d: "M9 12l4-4-4-4")
      end
    end
  end
end
