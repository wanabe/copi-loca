# frozen_string_literal: true

module Views
  module AuthSessions
    class New < Components::Base
      include Phlex::Rails::Helpers::FormAuthenticityToken

      def view_template
        h1 { plain "Login" }
        form(action: auth_sessions_path, method: "post") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          label { plain "Password:" }
          input(type: "password", name: "password", autocomplete: "off")
          button(type: "submit") { plain "Log in" }
        end
      end
    end
  end
end
