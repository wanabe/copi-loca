# frozen_string_literal: true

class Bin < TextFile
  PATH_PREFIX = Rails.root.join("bin/").to_s.freeze
  PATH_SUFFIX = ""
  ID_PATTERN = [/\A#{Regexp.escape(PATH_PREFIX)}(.*)\z/, 1].freeze

  attribute :id, :string

  def load
    self
  end

  def persisted?
    true
  end

  def run
    output = +""
    status = nil
    IO.popen(["ruby", path], err: %i[child out]) do |io|
      while (line = io.gets)
        output += line
      end
      _, status = Process.waitpid2(io.pid)
    end
    [status.to_i, output]
  end

  class << self
    def primary_condition(value)
      { id: value }
    end
  end
end
