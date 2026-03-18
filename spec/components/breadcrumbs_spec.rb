# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Breadcrumbs do
  subject(:rendered) { render described_class.new(breadcrumbs: breadcrumbs) }

  let(:root_crumb) { instance_double(Breadcrumb, name: "Home", path: "/", link?: true) }
  let(:link_crumb) { instance_double(Breadcrumb, name: "Projects", path: "/projects", link?: true) }
  let(:text_crumb) { instance_double(Breadcrumb, name: "Current Project", path: nil, link?: false) }
  let(:current_crumb) { instance_double(Breadcrumb, name: "Edit", path: nil, link?: false) }
  let(:breadcrumbs) { [root_crumb, link_crumb, text_crumb, current_crumb] }

  it "renders all breadcrumbs with correct links and current crumb styling" do
    expect(rendered).to include("aria-label=\"breadcrumb\"")
    expect(rendered).to include("Home")
    expect(rendered).to include("Projects")
    expect(rendered).to include("Current Project")
    expect(rendered).to include("Edit")
    expect(rendered).to include("href=\"/\"")
    expect(rendered).to include("href=\"/projects\"")
    expect(rendered).to match(%r{<span[^>]*aria-current="page"[^>]*>Edit</span>})
  end

  it "renders separators between crumbs except after the last" do
    expect(rendered.scan("<svg").size).to eq(3)
  end
end
