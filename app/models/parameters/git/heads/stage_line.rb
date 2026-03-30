# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Heads::StageLine < ApplicationParameter
  # @rbs!
  #   attr_accessor path(): String
  #   attr_accessor lineno(): Integer
  #   attr_reader for(): String
  #   attr_accessor hunk(): String

  attribute :path, :string
  attribute :lineno, :integer, default: 0
  attribute :for, :string
  attribute :hunk, :string

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  # @rbs value: String
  # @rbs return: void
  def for=(value)
    super(value == "edit" ? "edit" : "new")
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:path, :lineno, :for, :hunk)
  end
end
