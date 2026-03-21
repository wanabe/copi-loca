# frozen_string_literal: true
# rbs_inline: enabled

module Git
  class << self
    # @rbs *args: String
    # @rbs env: Hash[String, String]
    # @rbs return_status: bool
    # @rbs allow_failure: bool
    # @rbs return: String | bool
    def call(*args, env: {}, return_status: false, allow_failure: false)
      last_status, output = IO.popen(env, ["git", *args], "w+", err: %i[child out]) do |io|
        yield io if block_given?
        io.close_write
        [Process.wait2(io.pid).last, io.read]
      end

      return last_status.success? if return_status

      raise "Git failed: #{output}" if !allow_failure && !last_status.success?

      output
    end
  end
end
