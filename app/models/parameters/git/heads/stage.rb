# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Heads::Stage < ApplicationParameter
  # @rbs!
  #   attr_accessor ref(): String
  #   attr_accessor file_path(): String
  #   attr_reader amend(): bool

  attribute :ref, :string
  attribute :file_path, :string
  attribute :amend, :boolean

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  # @rbs value: String | bool
  # @rbs return: void
  def amend=(value)
    super(value == "true")
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:ref, :file_path, :amend)
  end
end
