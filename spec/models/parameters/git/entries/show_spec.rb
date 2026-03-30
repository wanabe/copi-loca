# frozen_string_literal: true

require "rails_helper"

RSpec.describe Parameters::Git::Entries::Show do
  describe "attributes" do
    it "has a ref attribute" do
      param = described_class.new(ref: "main")
      expect(param.ref).to eq("main")
    end

    it "has a path attribute" do
      param = described_class.new(path: "lib/file.rb")
      expect(param.path).to eq("lib/file.rb")
    end

    it "has a raw attribute with default true" do
      param = described_class.new({})
      expect(param.raw).to be(true)
    end

    it "can set raw to false" do
      param = described_class.new(raw: false)
      expect(param.raw).to be(false)
    end
  end

  describe "as_json" do
    it "returns a hash of attributes" do
      param = described_class.new(ref: "main", path: "lib/file.rb", raw: false)
      expect(param.as_json.symbolize_keys).to include(ref: "main", path: "lib/file.rb", raw: false)
    end
  end
end
