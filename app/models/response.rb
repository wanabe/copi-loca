# frozen_string_literal: true
# rbs_inline: enabled

class Response < TextFile
  PATH_PREFIX = Rails.root.join("docs/prompts/").to_s.freeze
  PATH_SUFFIX = "/response.md"
  ID_PATTERN = /\A#{Regexp.escape(PATH_PREFIX)}(\d+)#{Regexp.escape(PATH_SUFFIX)}\z/
  ID_PATTERN_INDEX = 1

  # @rbs!
  #   attr_accessor id (): Integer
  #   attr_accessor text (): String
  #   def self.find_by: (**untyped conditions) -> (Response | nil)

  attribute :id, :integer
  attribute :text, :string

  validates :id, presence: true
  validates :text, presence: true

  # @rbs return: void
  def template
    token :text, /.*/m
  end
end
