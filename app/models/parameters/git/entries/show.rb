# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Entries::Show < ApplicationParameter
  # @rbs!
  #   attr_accessor ref(): String
  #   attr_accessor path(): String
  #   attr_accessor raw(): bool

  attribute :ref, :string
  attribute :path, :string
  attribute :raw, :boolean, default: true
end
