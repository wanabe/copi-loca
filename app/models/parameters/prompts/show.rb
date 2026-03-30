# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): Integer

  attribute :id, :integer

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:id)
  end
end
