# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Heads::New < ApplicationParameter
  # @rbs!
  #   attr_accessor ref(): String
  #   attr_accessor open(): String

  attribute :ref, :string
  attribute :open, :string

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:ref, :open)
  end
end
