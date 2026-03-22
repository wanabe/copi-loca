# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Index < ApplicationParameter
  # @rbs!
  #   attr_accessor page(): Integer
  #   attr_accessor per_page(): Integer

  attribute :page, :integer, default: 1
  attribute :per_page, :integer, default: 5
end
