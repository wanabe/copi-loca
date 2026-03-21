# frozen_string_literal: true
# rbs_inline: enabled

class Git::Grep < ApplicationRepresenter
  # @rbs @pattern: String
  # @rbs @files: String?
  # @rbs @ignore_case: bool

  # @rbs!
  #   attr_accessor chunks (): Array[Git::Grep::Chunk]
  #   attr_accessor branch (): String?

  attribute :chunks
  attribute :branch

  # @rbs pattern: String
  # @rbs branch: String?
  # @rbs files: String?
  # @rbs ignore_case: bool
  # @rbs return: void
  def initialize(pattern:, branch: nil, files: nil, ignore_case: false)
    super()
    @pattern = pattern
    @files = files
    @ignore_case = ignore_case
    self.branch = branch.presence
  end

  # @rbs return: self
  def run
    args = [
      @ignore_case ? "-i" : nil,
      @pattern,
      branch.presence
    ].compact
    files = @files
    if files.present?
      args << "--"
      files.split("\n").each do |file|
        args << file.strip
      end
    end
    result = Git.call("grep", *args, allow_failure: true)
    raise "Unexpected result" unless result.is_a?(String)

    parse(result)
  end

  # @rbs return: void
  def template
    partial :chunks, Chunk, quantity: "*" do |event, chunk|
      chunk.branch = branch if event == :before
    end
  end

  class Chunk < ApplicationRepresenter
    # @rbs!
    #   attr_accessor branch (): String?
    #   attr_accessor lines (): Array[Git::Grep::Line]
    #   attr_accessor path (): String

    attribute :lines
    attribute :branch
    attribute :path

    # @rbs return: void
    def template
      partial :lines, Line, quantity: "+" do |event, line|
        case event
        when :before
          line.branch = branch if branch
          line.path = path if path
        when :after
          self.path ||= line.path
        end
      end
    end
  end

  class Line < ApplicationRepresenter
    # @rbs!
    #   attr_accessor branch (): String?
    #   attr_accessor path (): String
    #   attr_accessor content (): String

    attribute :branch
    attribute :path
    attribute :content

    # @rbs return: void
    def template
      line do
        if branch.present?
          same_as :branch
          literal ":"
        end
        token :path, /[^:]+/
        literal ":"
        token :content, /.*/
      end
    end
  end
end
