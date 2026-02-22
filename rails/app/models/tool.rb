class Tool < ApplicationRecord
  has_many :tool_parameters, dependent: :destroy
  accepts_nested_attributes_for :tool_parameters, allow_destroy: true

  after_initialize :load_script

  private
    def load_script
      return if script.blank?
      keyword_parameters = tool_parameters.map { |parameter| "#{parameter.name}: nil" }.join(", ")
      begin
        eval <<~RUBY
          class << self
            def call(#{keyword_parameters})
              #{script}
            end
          end
        RUBY
      rescue Exception => e
        Rails.logger&.error("Error loading script for tool #{name}: #{e.message}")
      end
    end
end
