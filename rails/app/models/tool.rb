# frozen_string_literal: true

class Tool < ApplicationRecord
  has_many :tool_parameters, dependent: :destroy
  accepts_nested_attributes_for :tool_parameters, allow_destroy: true

  validates :name, presence: true

  after_initialize :load_script

  private

  def load_script
    return if script.blank?

    keyword_parameters = tool_parameters.map { |parameter| "#{parameter.name}: nil" }.join(", ")
    begin
      # rubocop:disable Security/Eval
      eval <<~RUBY, binding, __FILE__, __LINE__ + 1
        class << self                      # class << self
          def call(#{keyword_parameters})  #   def call(arg1: nil, arg2: nil)
            #{script}                      #     arg1 + arg2
          end                              #   end
        end                                # end
      RUBY
      # rubocop:enable Security/Eval
    rescue Exception => e
      Rails.logger&.error("Error loading script for tool #{name}: #{e.message}")
    end
  end
end
