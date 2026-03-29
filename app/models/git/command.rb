# frozen_string_literal: true
# rbs_inline: enabled

class Git::Command < ApplicationRepresenter
  # @rbs return: String
  def command
    raise NotImplementedError
  end

  # @rbs *args: String
  # @rbs return: self
  def run(*args, &)
    result = Git.call(command, *args, &)
    raise "Unexpected result" unless result.is_a?(String)

    parse(result)
  end
end
