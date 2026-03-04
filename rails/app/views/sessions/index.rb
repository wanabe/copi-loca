# frozen_string_literal: true

module Views
  module Sessions
    class Index < Components::Base
      def initialize(sessions:)
        @sessions = sessions
      end

      def view_template
        view_context.content_for(:title, "Sessions")

        h1 { plain "Sessions" }
        render Components::Sessions::IndexComponent.new(sessions: @sessions)
      end
    end
  end
end
