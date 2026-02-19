class Tool < ApplicationRecord
  has_many :tool_parameters, dependent: :destroy
  accepts_nested_attributes_for :tool_parameters, allow_destroy: true
end
