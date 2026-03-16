# frozen_string_literal: true

class Views::Bin::Index < Views::Base
  def initialize(bins:, notice: nil)
    @bins = bins
    @notice = notice
  end

  def view_template
    p(class: "text-green-600 mb-4") { @notice } if @notice
    h1(class: "text-2xl font-bold mb-4") { "Bins" }
    table(id: "bins", class: "space-y-4") do
      thead do
        tr do
          th(class: "text-left font-semibold") { "ID" }
        end
      end
      tbody do
        @bins.each do |bin|
          tr do
            td(class: "border px-4 py-2") { link_to bin.id, bin_path(bin.id) }
          end
        end
      end
    end
    br
    render Components::Paginator.new(items: @bins)
  end
end
