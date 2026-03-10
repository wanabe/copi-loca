# frozen_string_literal: true

class Views::Ps::Index < Views::Base
  def initialize(ps:)
    @ps = ps
  end

  def view_template
    h1 { "Ps" }
    div(id: "ps") do
      @ps.each do |line|
        p { line }
      end
    end
  end
end

