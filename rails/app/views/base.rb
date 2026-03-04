# frozen_string_literal: true

# Minimal Views::Base used by legacy view classes during phlex migration.
class Views::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormAuthenticityToken
end
