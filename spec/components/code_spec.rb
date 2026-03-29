# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Code, type: :component do
  it "renders code with language class when language is provided" do
    rendered = render(described_class.new(code: "puts 'hi'", language: :ruby))
    expect(rendered).to include("language-ruby")
    expect(rendered).to include("puts &#39;hi&#39;")
  end

  it "detects language when :detect is passed" do
    component = described_class.new(code: "puts 'hi'", path: "foo.rb", language: :detect)
    expect(component.instance_variable_get(:@language)).to eq(:rb)
  end

  it "renders code without language class if language is nil" do
    rendered = render(described_class.new(code: "puts 'hi'"))
    expect(rendered).to include("<code")
    expect(rendered).to include("puts &#39;hi&#39;")
  end
end
