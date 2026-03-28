# frozen_string_literal: true
# rbs_inline: enabled

class Components::Layout < Components::Base
  # @rbs @view: Views::Base
  # @rbs @title: String
  # @rbs @breadcrumbs: Array[Breadcrumb]
  # @rbs @flash: Hash[Symbol, String]

  include Phlex::Rails::Layout

  # @rbs view: Views::Base
  # @rbs title: String?
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs flash: Hash[Symbol, String]
  # @rbs return: void
  def initialize(view:, title: nil, breadcrumbs: [], flash: {})
    @title = title || "Copi Loca"
    @breadcrumbs = breadcrumbs
    @flash = flash
    @view = view
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
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        link(rel: "manifest", href: pwa_manifest_path(format: :json))
        render stylesheet_link_tag("tailwind", "data-turbo-track": "reload")
        render javascript_importmap_tags
      end
      body do
        render Components::Breadcrumbs.new(breadcrumbs: @breadcrumbs)
        render(@flash.map { |type, message| Components::Flash.new(type: type, message: message) })
        div(class: "px-2", &)
      end
    end
  end
end
