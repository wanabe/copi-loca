# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Index < ApplicationParameter
  # @rbs!
  #   attr_accessor page(): Integer
  #   attr_accessor per_page(): Integer

  attribute :page, :integer, default: 1
  attribute :per_page, :integer, default: 5

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:page, :per_page)
  end
end
