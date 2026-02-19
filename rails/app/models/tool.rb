class Tool < ApplicationRecord
  has_many :tool_parameters, dependent: :destroy
end
