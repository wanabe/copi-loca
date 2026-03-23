# frozen_string_literal: true
# rbs_inline: enabled

class Git::LsTree < Git::Command
  # @rbs @ref: String
  # @rbs @path: String
  # @rbs @entries: Array[Git::LsTree::Entry]

  # @rbs!
  #   attr_accessor ref (): String
  #   attr_accessor path (): String
  #   attr_accessor entries (): Array[Git::LsTree::Entry]

  attribute :path, :string
  attribute :ref, :string
  attribute :entries

  # @rbs return: String
  def command
    "ls-tree"
  end

  # @rbs return: self
  def run
    args = [
      ref.presence,
      "--",
      path.presence || "."
    ].compact
    super(*args)
  end

  # @rbs return: void
  def template
    partial :entries, Entry, quantity: "*"
  end

  class Entry < ApplicationRepresenter
    # @rbs!
    #   attr_accessor mode (): String
    #   attr_accessor type (): String
    #   attr_accessor hash (): String
    #   attr_accessor path (): String

    attribute :mode, :string
    attribute :type, :string
    attribute :hash, :string
    attribute :path, :string

    # @rbs return: void
    def template
      line do
        token :mode, /\d+/
        literal " "
        token :type, /tree|blob|commit/
        literal " "
        token :hash, /[0-9a-f]*/
        literal "\t"
        token :path, /.*/
      end
    end
  end
end
