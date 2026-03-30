# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Refs::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor ref(): String

  attribute :ref, :string

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:ref)
  end
end
