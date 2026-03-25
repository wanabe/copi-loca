# frozen_string_literal: true
# rbs_inline: enabled

class Git::LsFiles < Git::Command
  # @rbs @entries: Array[Git::LsTree::Entry]
  # @rbs @others: bool
  # @rbs @exclude_standard: bool

  # @rbs!
  #   attr_accessor entries (): Array[Git::LsTree::Entry]
  #   attr_accessor others (): bool
  #   attr_accessor exclude_standard (): bool

  attribute :entries, default: lambda {
    [] #: Array[Git::LsTree::Entry]
  }
  attribute :others, :boolean, default: false
  attribute :exclude_standard, :boolean, default: false

  # @rbs return: String
  def command
    "ls-files"
  end

  # @rbs return: self
  def run
    args = [
      others ? "--others" : nil,
      exclude_standard ? "--exclude-standard" : nil
    ].compact
    super(*args)
  end

  # @rbs return: void
  def template
    partial :entries, Entry, quantity: "*"
  end

  class Entry < ApplicationRepresenter
    attribute :path, :string

    # @rbs return: void
    def template
      line do
        token :path, /.*/
      end
    end
  end
end
