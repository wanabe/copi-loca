# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Files::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor path(): String
  #   attr_accessor raw(): bool
  #   def self.from: (ActionController::Parameters) -> Parameters::Files::Show?

  attribute :path, :string, default: "."
  attribute :raw, :boolean, default: true

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:path, :raw)
  end
end
