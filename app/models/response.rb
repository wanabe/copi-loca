# frozen_string_literal: true

class Response < TextFile
  PATH_PREFIX = Rails.root.join("docs/prompts/").to_s.freeze
  PATH_SUFFIX = "/response.md"
  ID_PATTERN = [/\A#{Regexp.escape(PATH_PREFIX)}(\d+)#{Regexp.escape(PATH_SUFFIX)}\z/, 1].freeze

  attribute :id, :integer
  attribute :text, :string

  validates :id, presence: true
  validates :text, presence: true

  def template
    token :text, /.*/m
  end
end
