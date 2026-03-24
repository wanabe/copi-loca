# frozen_string_literal: true
# rbs_inline: enabled

class Git::Log < Git::Command
  # @rbs @ref: String
  # @rbs @commits: Array[Git::Log::Commit]

  # @rbs!
  #   attr_accessor ref (): String
  #   attr_accessor commits (): Array[Git::Log::Commit]

  attribute :ref, :string
  attribute :commits

  # @rbs return: String
  def command
    "log"
  end

  # @rbs return: self
  def run
    super(
      "--pretty=format:%H%x09%an%x09%ae%x09%aI%x09%cI%x09%s",
      ref
    )
  end

  # @rbs result: String
  # @rbs return: self
  def parse(result)
    result += "\n" unless result.end_with?("\n")
    super
  end

  # @rbs return: void
  def template
    partial :commits, Commit, quantity: "*"
  end

  class Commit < ApplicationRepresenter
    # @rbs!
    #  attr_accessor commit_hash (): String
    #  attr_accessor author_name (): String
    #  attr_accessor author_email (): String
    #  attr_accessor author_date (): DateTime
    #  attr_accessor committer_date (): DateTime
    #  attr_accessor message (): String

    attribute :commit_hash, :string
    attribute :author_name, :string
    attribute :author_email, :string
    attribute :author_date, :datetime
    attribute :committer_date, :datetime
    attribute :message, :string

    # @rbs return: void
    def template
      line do
        token :commit_hash, /[0-9a-f]+/
        literal "\t"
        token :author_name, /[^\t\n]+/
        literal "\t"
        token :author_email, /[^\t\n]+/
        literal "\t"
        token :author_date, /[^\t\n]+/, to: :to_datetime, from: :iso8601
        literal "\t"
        token :committer_date, /[^\t\n]+/, to: :to_datetime, from: :iso8601
        literal "\t"
        token :message, /[^\n]+/
      end
    end
  end
end
