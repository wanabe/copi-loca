# frozen_string_literal: true
# rbs_inline: enabled

class Git::Grep < Git::Command
  # @rbs @pattern: String
  # @rbs @files: String?
  # @rbs @ignore_case: bool

  # @rbs!
  #   attr_accessor chunks (): Array[Git::Grep::Chunk]?
  #   attr_accessor ref (): String?

  attribute :chunks
  attribute :ref

  # @rbs pattern: String
  # @rbs ref: String?
  # @rbs files: String?
  # @rbs ignore_case: bool
  # @rbs chunks: Array[Git::Grep::Chunk]?
  # @rbs return: void
  def initialize(pattern:, ref: nil, files: nil, ignore_case: false, chunks: nil)
    super(ref: ref.presence, chunks: chunks)
    @pattern = pattern
    @files = files
    @ignore_case = ignore_case
  end

  # @rbs return: String
  def command
    "grep"
  end

  # @rbs return: self
  def run
    args = [
      @ignore_case ? "-i" : nil,
      @pattern,
      ref.presence
    ].compact
    files = @files
    if files.present?
      args << "--"
      files.split("\n").each do |file|
        args << file.strip
      end
    end
    super(*args)
  end

  # @rbs return: void
  def template
    partial :chunks, Chunk, quantity: "*" do |event, chunk|
      chunk.ref = ref if event == :before
    end
  end

  class Chunk < ApplicationRepresenter
    # @rbs!
    #   attr_accessor ref (): String?
    #   attr_accessor lines (): Array[Git::Grep::Line]
    #   attr_accessor path (): String

    attribute :lines
    attribute :ref
    attribute :path

    # @rbs return: void
    def template
      partial :lines, Line, quantity: "+" do |event, line|
        case event
        when :before
          line.ref = ref if ref
          line.path = path if path
        when :after
          self.path ||= line.path
        end
      end
    end
  end

  class Line < ApplicationRepresenter
    # @rbs!
    #   attr_accessor ref (): String?
    #   attr_accessor path (): String
    #   attr_accessor content (): String

    attribute :ref
    attribute :path
    attribute :content

    # @rbs return: void
    def template
      line do
        if ref.present?
          same_as :ref
          literal ":"
        end
        token :path, /[^:]+/
        literal ":"
        token :content, /.*/
      end
    end
  end
end
