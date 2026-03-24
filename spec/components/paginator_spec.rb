# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Paginator, type: :component do
  subject(:rendered) { render paginator }

  let(:paginator) { described_class.new(items: items, params: params, remote: false) }
  let(:params) { { search: "foo" } }

  before do
    allow(paginator).to receive(:url_for) { |**args| "/dummy?page=#{args[:page]}&per_page=#{args[:per_page]}".html_safe }
  end

  describe "#view_template" do
    context "when on middle page" do
      let(:items) { Kaminari.paginate_array((1..50).to_a).page(2).per(10) }

      it "renders navigation with correct links and current page" do
        expect(rendered).to include("navigation")
        expect(rendered).to include(ERB::Util.html_escape("<First"))
        expect(rendered).to include(ERB::Util.html_escape("<Prev"))
        expect(rendered).to include(ERB::Util.html_escape("Next>"))
        expect(rendered).to include(ERB::Util.html_escape("Last(5)>"))
        expect(rendered).to include("px-2 py-1 bg-blue-500 text-white rounded") # current page styling
        expect(rendered).to include("/dummy?page=1&per_page=10")
        expect(rendered).not_to include("/dummy?page=2&per_page=10")
        expect(rendered).to include("/dummy?page=3&per_page=10")
        expect(rendered).to include("/dummy?page=5&per_page=10")
      end
    end

    context "when on first page" do
      let(:items) { Kaminari.paginate_array((1..50).to_a).page(1).per(10) }

      it "does not render <First and <Previous" do
        expect(rendered).not_to include(ERB::Util.html_escape("<First"))
        expect(rendered).not_to include(ERB::Util.html_escape("<Previous"))
      end
    end

    context "when on last page" do
      let(:items) { Kaminari.paginate_array((1..50).to_a).page(5).per(10) }

      it "does not render Next> and Last> on last page" do
        expect(rendered).not_to include(ERB::Util.html_escape("Next>"))
        expect(rendered).not_to include(ERB::Util.html_escape("Last>"))
      end
    end
  end
end
