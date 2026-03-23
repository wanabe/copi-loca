# frozen_string_literal: true
# rbs_inline: enabled

class Git::Show < Git::Command
  # @rbs @ref: String
  # @rbs @path: String
  # @rbs @content: String

  # @rbs!
  #   attr_accessor ref (): String
  #   attr_accessor path (): String
  #   attr_accessor content (): String

  attribute :path, :string
  attribute :ref, :string
  attribute :content, :string

  # @rbs return: String
  def command
    "show"
  end

  # @rbs return: self
  def run
    args = [
      "#{ref.presence}:#{path.presence || '.'}"
    ].compact
    super(*args)
  end

  # @rbs return: void
  def template
    token :content, /.*/m
  end
end
