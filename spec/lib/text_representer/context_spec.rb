# frozen_string_literal: true

require "rails_helper"
require "text_representer"

RSpec.describe TextRepresenter::Context do
  let(:context_class) { described_class }
  let(:context) { context_class.new }

  describe "#partial" do
    it "raises NotImplementedError" do
      expect do
        context.partial(:representer, :name, String)
      end.to raise_error(NotImplementedError, /Context#partial must be implemented by subclasses/)
    end
  end

  describe "#literal" do
    it "raises NotImplementedError" do
      expect do
        context.literal(:representer, "string")
      end.to raise_error(NotImplementedError, /Context#literal must be implemented by subclasses/)
    end
  end

  describe "#token" do
    it "raises NotImplementedError" do
      expect do
        context.token(:representer, :name, /regex/)
      end.to raise_error(NotImplementedError, /Context#token must be implemented by subclasses/)
    end
  end

  describe "#line" do
    it "raises NotImplementedError" do
      expect do
        context.line
      end.to raise_error(NotImplementedError, /Context#line must be implemented by subclasses/)
    end
  end

  describe "#optional" do
    it "raises NotImplementedError" do
      expect do
        context.optional(:representer, :name) {}
      end.to raise_error(NotImplementedError, /Context#optional must be implemented by subclasses/)
    end
  end

  describe "#absence" do
    it "raises NotImplementedError" do
      expect do
        context.absence(:representer) {}
      end.to raise_error(NotImplementedError, /Context#absence must be implemented by subclasses/)
    end
  end

  describe "#same_as" do
    it "raises NotImplementedError" do
      expect do
        context.same_as(:representer, :name)
      end.to raise_error(NotImplementedError, /Context#same_as must be implemented by subclasses/)
    end
  end
end
