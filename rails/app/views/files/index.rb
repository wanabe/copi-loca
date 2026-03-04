# frozen_string_literal: true

class Views::Files::Index < Views::Base
  def initialize(tree:)
    @tree = tree
  end

  def view_template
    h1 { plain "Files in /app" }
    render Components::Files::TreeComponent.new(tree: @tree, path: "")
  end
end
