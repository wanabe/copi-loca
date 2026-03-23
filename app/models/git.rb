# frozen_string_literal: true
# rbs_inline: enabled

module Git
  class << self
    # @rbs *args: String
    # @rbs env: Hash[String, String]
    # @rbs &: ? (IO) -> void
    # @rbs return: bool
    def call?(*args, env: {}, &)
      status, = call_status_and_output(*args, env: env, &)
      status.success?
    end

    # @rbs *args: String
    # @rbs env: Hash[String, String]
    # @rbs &: ? (IO) -> void
    # @rbs return: String
    def call!(*args, env: {}, &)
      status, output = call_status_and_output(*args, env: env, &)
      raise "Git failed: #{output}" unless status.success?

      output
    end

    # @rbs *args: String
    # @rbs env: Hash[String, String]
    # @rbs &: ? (IO) -> void
    # @rbs return: String
    def call(*args, env: {}, &)
      _, output = call_status_and_output(*args, env: env, &)
      output
    end

    private

    # @rbs *args: String
    # @rbs env: Hash[String, String]
    # @rbs &: ? (IO) -> void
    # @rbs return: [Process::Status, String]
    def call_status_and_output(*args, env: {}, &)
      IO.popen(env, ["git", *args], "w+", err: %i[child out]) do |io|
        yield io if block_given?
        io.close_write
        [Process.wait2(io.pid).last, io.read]
      end
    end
  end
end
