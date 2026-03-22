# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Bin::Member < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): String

  attribute :id, :string
end
