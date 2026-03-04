# frozen_string_literal: true

module Views
  module Files
    class Show < Components::Base
      def initialize(path:, content:, language:)
        @path = path
        @content = content
        @language = language
      end

      def view_template
        render Components::Files::ShowComponent.new(path: @path, content: @content, language: @language)
      end
    end
  end
end
