# frozen_string_literal: true

module Views
  module Models
    class Index < Components::Base
      def initialize(models:, open_id: nil)
        @models = models
        @open_id = open_id
      end

      def view_template
        h1 { plain "Available AI Models" }
        ul do
          @models.each do |model|
            li do
              details(id: "model_#{model[:id]}", open: (model[:id].to_s == @open_id.to_s)) do
                summary { plain "#{model[:id]} (x#{model.dig(:billing, :multiplier)})" }
                render(Components::Models::DataComponent.new(data: model, key: nil))
              end
            end
          end
        end
      end
    end
  end
end
