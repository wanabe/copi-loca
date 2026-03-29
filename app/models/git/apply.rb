# frozen_string_literal: true
# rbs_inline: enabled

class Git::Apply < Git::Command
  # @rbs!
  #   attr_accessor patch (): Git::Diff::Patch
  #   attr_accessor output (): String

  attribute :patch
  attribute :output, :string

  # @rbs return: String
  def command
    "apply"
  end

  # @rbs output: String
  # @rbs return: self
  def parse(output)
    self.output = output
    self
  end

  # @rbs *args: String
  # @rbs return: self
  def run(*args, &)
    super("--cached", "--unidiff-zero", "-", *args) do |io|
      io.write patch.render
      yield if block_given?
    end
  end

  class << self
    # @rbs path: String
    # @rbs hunk_str: String
    # @rbs lineno: Integer
    # @rbs reverse: bool
    # @rbs return: Git::Apply
    def pick_line(path, hunk_str, lineno, reverse: false)
      hunk_str << "\n" until hunk_str.end_with?("\n")
      hunk = Git::Diff::Hunk.new.parse(hunk_str)
      hunk.reverse if reverse
      hunk.drop_if { |line| line.lineno != lineno }
      header = Git::Diff::Header.new(src_path: path, dst_path: path, src_file: path, dst_file: path)
      patch = Git::Diff::Patch.new(header: header, hunks: [hunk])
      new(patch: patch).run
    end
  end
end
