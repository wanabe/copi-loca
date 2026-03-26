# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Flash do
  describe "#alert_class" do
    subject(:component) { described_class.new(type: type, message: "msg") }

    context "when type is :notice" do
      let(:type) { :notice }

      it "returns green classes" do
        expect(component.send(:alert_class, type)).to eq("bg-green-100 text-green-800")
      end
    end

    context "when type is :alert" do
      let(:type) { :alert }

      it "returns red classes" do
        expect(component.send(:alert_class, type)).to eq("bg-red-100 text-red-800")
      end
    end

    context "when type is something else" do
      let(:type) { :other }

      it "returns gray classes" do
        expect(component.send(:alert_class, type)).to eq("bg-gray-100 text-gray-800")
      end
    end
  end
end
