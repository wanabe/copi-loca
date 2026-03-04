# frozen_string_literal: true

class Components::Shared::BreadcrumbsComponent < Phlex::HTML
  def initialize(breadcrumbs:, session: nil)
    @breadcrumbs = breadcrumbs
    @session = session
  end

  def view_template
    nav(aria: { label: "breadcrumb" }, class: %w[mobile-breadcrumbs breadcrumbs-nav]) do
      ol(class: %w[breadcrumb breadcrumbs-list]) do
        @breadcrumbs.each do |crumb|
          li(class: %w[breadcrumb-item]) do
            if crumb.link? && crumb != @breadcrumbs.last
              a(href: crumb.path, class: %w[breadcrumb-link]) { plain crumb.name }
            else
              span(class: %w[breadcrumb-page]) { plain crumb.name }
            end
          end
        end
      end

      span(class: %w[session-model breadcrumbs-session-model]) { plain @session.model } if @session&.model.present?
    end
  end
end
