# frozen_string_literal: true

class Components::Bin::Bin < Components::Base
  def initialize(bin:)
    @bin = bin
  end

  def view_template
    div(id: dom_id(@bin)) do
      h2(class: "text-xl font-bold") { @bin.id }
    end
  end
end
