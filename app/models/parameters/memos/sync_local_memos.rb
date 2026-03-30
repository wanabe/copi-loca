# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Memos::SyncLocalMemos < ApplicationParameter
  attribute :memos, array: true

  # @rbs params: ActionController::Parameters
  # @rbs return: void
  def initialize(params)
    super(permitted_params(params))
  end

  # @rbs array: Array[Hash[String, String]]
  # @rbs return: void
  def memos=(array)
    memos = array.map do |memo_hash|
      Memo.new(ActionController::Parameters.new(memo_hash.slice("text", "ts")).permit(:text, :ts).to_h.symbolize_keys)
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

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(memos: %i[text ts])
  end
end
