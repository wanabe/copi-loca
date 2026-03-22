# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Run < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): Integer
  #   attr_accessor n(): Integer

  attribute :id, :integer
  attribute :n, :integer, default: 1
end
