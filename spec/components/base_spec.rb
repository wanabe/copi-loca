# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Base do
  subject(:component) { described_class.new }

  describe "#initialize" do
    it "includes Phlex Rails helpers" do
      expect(component).to be_a(Phlex::HTML)
      expect(component).to respond_to(:form_with)
      expect(component).to respond_to(:pluralize)
      expect(component).to respond_to(:dom_id)
      expect(component).to respond_to(:content_for)
    end
  end
end
