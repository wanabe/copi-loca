# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Member < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): Integer

  attribute :id, :integer
end
