# frozen_string_literal: true
# rbs_inline: enabled

class Views::Bin::Index < Views::Base
  # @rbs @bins: Kaminari::PaginatableArray[Bin]
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs bins: Kaminari::PaginatableArray[Bin]
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(bins:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @bins = bins
  end

  # @rbs return: void
  def body_template
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
            td(class: "border px-4 py-2") { link_to bin.id.to_s, bin_path(bin.id) }
          end
        end
      end
    end
    br
    render Components::Paginator.new(items: @bins)
  end
end
