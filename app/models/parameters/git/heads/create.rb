# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Heads::Create < ApplicationParameter
  # @rbs!
  #   attr_accessor ref(): String
  #   attr_accessor commit_message(): String

  attribute :ref, :string
  attribute :commit_message, :string

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:ref, :commit_message)
  end
end
