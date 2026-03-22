# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Prompt < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): Integer
  #   attr_accessor name(): String
  #   attr_accessor description(): String
  #   attr_accessor text(): String

  attribute :id, :integer
  attribute :name, :string
  attribute :description, :string
  attribute :text, :string
end
