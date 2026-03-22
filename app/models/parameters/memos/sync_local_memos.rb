# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Memos::SyncLocalMemos < ApplicationParameter
  attribute :memos, array: true

  # @rbs array: Array[Hash[String, String]]
  # @rbs return: void
  def memos=(array)
    memos = array.map do |memo_hash|
      Memo.new(**memo_hash.slice("text", "ts").symbolize_keys)
    end
    super(memos)
  end

  class Memo < ApplicationParameter
    # @rbs!
    #   attr_accessor text(): String
    #   attr_accessor ts(): Integer

    attribute :text, :string
    attribute :ts, :integer
  end
end
