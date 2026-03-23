# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Entries::ShowTree do
  subject(:rendered) { render described_class.new(ref: ref, path: path, entries: entries) }

  let(:ref) { "main" }
  let(:path) { "src" }
  let(:entries) do
    [
      instance_double(Git::LsTree::Entry, type: "tree", path: "src/lib"),
      instance_double(Git::LsTree::Entry, type: "blob", path: "src/file.txt"),
      instance_double(Git::LsTree::Entry, type: "unknown", path: "src/other")
    ]
  end

  it "renders the tree header" do
    expect(rendered).to match(%r{<h1[^>]*>Tree #{ref}:#{path}</h1>})
  end

  it "renders directory entries as folders with links" do
    expect(rendered).to include("\u{1F4C1}")
    expect(rendered).to include('href="/git/entries/main/-/src/lib"')
  end

  it "renders blob entries as files with links and raw links" do
    expect(rendered).to include("\u{1F4C4}")
    expect(rendered).to include('href="/git/entries/main/-/src/file.txt?raw=false"')
    expect(rendered).to include('href="/git/entries/main/-/src/file.txt"')
    expect(rendered).to include(" (raw)")
  end

  it "renders unknown entry types with a question mark" do
    expect(rendered).to include("\u{2753}")
    expect(rendered).to include("other")
  end
end
