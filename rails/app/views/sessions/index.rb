# frozen_string_literal: true

class Views::Sessions::Index < Views::Base
  def initialize(sessions:)
    @sessions = sessions
  end

  def view_template
    content_for(:title, "Sessions")
    h1 { plain "Sessions" }

    table(id: "sessions") do
      thead do
        tr do
          th { plain "id" }
          th { plain "Model" }
          th { plain "links" }
        end
      end

      tbody do
        @sessions.each do |session|
          render Components::Sessions::TableRowComponent.new(session: session)
        end
      end
    end

    div do
      a(href: new_session_path) { plain "New session" }
    end
  end
end
