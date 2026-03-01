# frozen_string_literal: true

class CustomAgent < ApplicationRecord
  validates :name, presence: true
end
