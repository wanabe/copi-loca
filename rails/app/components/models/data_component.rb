# frozen_string_literal: true

module Components
  module Models
    class DataComponent < Components::Base
      def initialize(data:, key: nil)
        @data = data
        @key = key
      end

      def view_template
        if @data.is_a?(Hash) && @key.present?
          details do
            summary { plain @key }
            ul do
              @data.each do |k, v|
                li { render Components::Models::DataComponent.new(data: v, key: k) }
              end
            end
          end
        elsif @data.is_a?(Hash)
          ul do
            @data.each do |k, v|
              li { render Components::Models::DataComponent.new(data: v, key: k) }
            end
          end
        elsif @data.is_a?(Array) && @key.present?
          details do
            summary { plain "#{@key} (#{@data.size} items)" }
            ol do
              @data.each do |item|
                li { render Components::Models::DataComponent.new(data: item, key: nil) }
              end
            end
          end
        elsif @data.is_a?(Array)
          ol do
            @data.each do |item|
              li { render Components::Models::DataComponent.new(data: item, key: nil) }
            end
          end
        else
          span do
            strong { plain "#{@key}:" }
            plain " "
            plain @data.to_s
          end
        end
      end
    end
  end
end
