# frozen_string_literal: true
# rbs_inline: enabled

class Breadcrumb
  attr_reader :name #: String
  attr_reader :path #: String?

  # @rbs name: String
  # @rbs path: String?
  # @rbs return: void
  def initialize(name, path)
    @name = name
    @path = path
  end

  # @rbs return: bool
  def link?
    @path.present?
  end
end
