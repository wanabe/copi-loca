# frozen_string_literal: true

module Components
  class Base < Phlex::HTML
    # Include any helpers you want to be available across all components
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::FormAuthenticityToken
  end
end
