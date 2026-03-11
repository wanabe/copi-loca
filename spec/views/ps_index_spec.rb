# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Views::Ps::Index do
  subject(:rendered) { render described_class.new(lines: lines) }
  let(:lines) { ["Line 1", "Line 2"] }

  describe '#view_template' do
    it 'renders the Ps header' do
      expect(rendered).to include('<h1>Ps</h1>')
    end

    it 'renders each line inside the ps div' do
      expect(rendered).to include('<div id="ps">')
      lines.each do |line|
        expect(rendered).to include("<p>#{line}</p>")
      end
    end
  end
end
