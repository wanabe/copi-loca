# frozen_string_literal: true
# rbs_inline: enabled

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # More caching options at https://www.phlex.fun/components/caching

  # @rbs return: untyped # TODO: Specify more precise type if possible
  def cache_store = Rails.cache
end
