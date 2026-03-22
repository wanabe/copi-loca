# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Files::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor path(): String
  #   attr_accessor raw(): bool

  attribute :path, :string, default: "."
  attribute :raw, :boolean, default: true
end
