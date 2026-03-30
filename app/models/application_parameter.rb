# frozen_string_literal: true
# rbs_inline: enabled

class ApplicationParameter
  include ActiveModel::Model
  include ActiveModel::Attributes

  # For RBS
  extend ActiveModel::Attributes::ClassMethods

  # @rbs return: Hash[Symbol, untyped]
  def as_json(...)
    attributes.as_json(...)
  end

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(**params)
  end

  class << self
    # @rbs return: String
    def action_name
      name.demodulize.underscore
    end

    # @rbs params: ActionController::Parameters
    # @rbs return: ApplicationParameter?
    def from(params)
      return if params[:action] != action_name

      new(params)
    end
  end
end
