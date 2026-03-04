# frozen_string_literal: true

class Components::Sessions::TableRowComponent < Components::Base
  def initialize(session:)
    @session = session
  end

  def view_template
    tr do
      td { a(href: session_path(@session)) { plain @session.id } }
      td { plain @session.model }
      td
    end
  end
end
