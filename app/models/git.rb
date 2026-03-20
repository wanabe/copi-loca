# frozen_string_literal: true

module Git
  class << self
    def call(*args, env: {}, return_status: false, allow_failure: false)
      output = IO.popen(env, ["git", *args], "w+", err: %i[child out]) do |io|
        yield io if block_given?
        io.close_write
        io.read
      end

      return Process.last_status.success? if return_status

      raise "Git failed: #{output}" if !allow_failure && !Process.last_status.success?

      output
    end
  end
end
