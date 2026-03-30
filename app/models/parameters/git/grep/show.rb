# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Grep::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor pattern(): String?
  #   attr_accessor files(): String
  #   attr_accessor ref(): String
  #   attr_reader ignore_case(): bool

  attribute :pattern, :string
  attribute :files, :string, default: ""
  attribute :ref, :string, default: ""
  attribute :ignore_case, :boolean, default: false

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  # @rbs value: String
  # @rbs return: bool
  def ignore_case=(value)
    super(value == "on")
  end

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:pattern, :files, :ref, :ignore_case)
  end
end
