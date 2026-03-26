# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Prompts::Index do
  subject(:rendered) { render described_class.new(prompts: prompts) }

  let(:prompts) { Kaminari.paginate_array([Prompt.new(id: 1), Prompt.new(id: 2)]).page(1).per(10) }

  before do
    prompts.each { |prompt| allow(prompt).to receive(:persisted?).and_return(true) }
  end

  it "renders the Prompts title" do
    expect(rendered).to match(%r{<h1[^>]*>Prompts</h1>})
  end

  it "renders each prompt with show link" do
    prompts.each do |prompt|
      expect(rendered).to include("/prompts/#{prompt.id}")
    end
  end

  it "renders the New prompt link" do
    expect(rendered).to include("/prompts/new")
    expect(rendered).to include("New prompt")
  end
end
