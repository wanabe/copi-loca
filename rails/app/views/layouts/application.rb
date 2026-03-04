# frozen_string_literal: true

module Views
  module Layouts
    class Application < Views::Base
      include Phlex::Rails::Layout
      include Phlex::Rails::Helpers::ContentFor
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::TurboFrameTag

      def initialize(breadcrumbs: [], session: nil)
        @breadcrumbs = breadcrumbs
        @session = session
      end

      def view_template
        doctype
        html do
          head do
            title { content_for(:title) || "Copi Loca" }
            meta name: "viewport", content: "width=device-width,initial-scale=1"
            meta name: "apple-mobile-web-app-capable", content: "yes"
            meta name: "application-name", content: "Copi Loca"
            meta name: "mobile-web-app-capable", content: "yes"
            csrf_meta_tags
            csp_meta_tag

            yield :head

            # Prism.js
            link rel: "stylesheet", href: "https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css"
            script src: "https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"
            script src: "https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"

            # Enable PWA manifest for installable apps (make sure to enable in config/routes.rb too!) %>
            #= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>

            link rel: "icon", href: "/icon.png", type: "image/png"
            link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
            link rel: "apple-touch-icon", href: "/icon.png"

            # Includes all stylesheet files in app/assets/stylesheets
            stylesheet_link_tag :app, "data-turbo-track": "reload"
            javascript_importmap_tags
          end

          body do
            render Components::Shared::BreadcrumbsComponent.new(breadcrumbs: @breadcrumbs, session: @session)
            if flash[:notice].present?
              p class: "layout__flash--notice" do
                flash[:notice]
              end
            end
            if flash[:alert].present?
              p class: "layout__flash--alert" do
                flash[:alert]
              end
            end
            yield
            turbo_frame_tag :remote_modal
          end
        end
      end
    end
  end
end
