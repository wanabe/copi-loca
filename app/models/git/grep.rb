# frozen_string_literal: true

class Git::Grep
  include ActiveModel::Model
  include ActiveModel::Attributes
  include TextRepresenter::Representable

  attribute :chunks
  attribute :branch

  def initialize(pattern:, branch: nil, files: nil, ignore_case: false)
    super()
    @pattern = pattern
    @files = files
    self.branch = branch.presence
    @ignore_case = ignore_case
  end

  def run
    args = []
    args << "-i" if @ignore_case
    args << @pattern
    args << branch if branch.present?
    if @files.present?
      args << "--"
      @files.split("\n").each do |file|
        args << file.strip
      end
    end
    parse(Git.call("grep", *args, allow_failure: true))
  end

  def template
    partial :chunks, Chunk, quantity: "*" do |event, chunk|
      chunk.branch = branch if event == :before
    end
  end

  class Chunk
    include ActiveModel::Model
    include ActiveModel::Attributes
    include TextRepresenter::Representable

    attribute :lines
    attribute :branch
    attribute :path

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

  class Line
    include ActiveModel::Model
    include ActiveModel::Attributes
    include TextRepresenter::Representable

    attribute :branch
    attribute :path
    attribute :content

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
