# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Bin::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor id(): String
  #   def self.from: (ActionController::Parameters) -> Parameters::Bin::Show?

  attribute :id, :string

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(params.permit(:id))
  end
end
