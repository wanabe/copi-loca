# frozen_string_literal: true
# rbs_inline: enabled

class Views::Layouts::Application < Views::Base
  # @rbs @title: String
  # @rbs @breadcrumbs: Array[Breadcrumb]

  include Phlex::Rails::Layout

  # @rbs title: String?
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(title: nil, breadcrumbs: [])
    @title = title || "Copi Loca"
    @breadcrumbs = breadcrumbs
  end

  # @rbs return: void
  def view_template(&)
    doctype
    html do
      head do
        title { @title }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: "Copi Loca")
        meta(name: "mobile-web-app-capable", content: "yes")
        render csrf_meta_tags
        render csp_meta_tag
        yield :head
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        link(rel: "manifest", href: pwa_manifest_path(format: :json))
        render stylesheet_link_tag("tailwind", "data-turbo-track": "reload")
        render javascript_importmap_tags
      end
      body do
        render Components::Breadcrumbs.new(breadcrumbs: @breadcrumbs)
        div(class: "px-2", &)
      end
    end
  end
end
