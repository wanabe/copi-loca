# frozen_string_literal: true

class Views::Ps::Index < Views::Base
  def initialize(lines:)
    @lines = lines
  end

  def view_template
    h1 { "Ps" }
    div(id: "ps") do
      @lines.each do |line|
        p { line }
      end
    end
  end
end
