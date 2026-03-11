# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Views::Base do
  describe 'inheritance' do
    it 'inherits from Components::Base' do
      expect(described_class.superclass).to eq(Components::Base)
    end
  end

  describe '#cache_store' do
    it 'returns Rails.cache' do
      expect(described_class.new.cache_store).to eq(Rails.cache)
    end
  end
end
