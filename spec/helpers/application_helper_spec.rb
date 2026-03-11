# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  it 'is defined as a module' do
    expect(defined?(ApplicationHelper)).to eq('constant')
    expect(ApplicationHelper).to be_a(Module)
  end
end

