# frozen_string_literal: true
# rbs_inline: enabled

class Bin < TextFile
  PATH_PREFIX = Rails.root.join("bin/").to_s.freeze
  PATH_SUFFIX = ""
  ID_PATTERN = /\A#{Regexp.escape(PATH_PREFIX)}(.*)\z/
  ID_PATTERN_INDEX = 1

  # @rbs!
  #   attr_accessor id (): Integer
  #   def self.find: (untyped value) -> Bin
  #   def self.all: () -> Array[Bin]

  attribute :id, :string

  # @rbs return: self
  def load
    self
  end

  # @rbs return: bool
  def persisted?
    true
  end

  # @rbs return: [Integer, String]
  def run
    output = +""
    status = nil
    IO.popen([path], err: %i[child out]) do |io|
      while (line = io.gets)
        output += line
      end
      _, status = Process.waitpid2(io.pid)
    end
    [status.to_i, output]
  end

  class << self
    # @rbs value: untyped # TODO: Specify type
    # @rbs return: Hash[Symbol, untyped]
    def primary_condition(value)
      { id: value }
    end
  end
end
