# frozen_string_literal: true

class SessionTool < ApplicationRecord
  belongs_to :session
  belongs_to :tool
end
