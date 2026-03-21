# frozen_string_literal: true
# rbs_inline: enabled

class Components::Base < Phlex::HTML
  # rbs_inline: enabled
  # No instance variables or methods to annotate at this level
  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::TurboFrameTag
end
