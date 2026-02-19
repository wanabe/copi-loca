class SessionCustomAgent < ApplicationRecord
  belongs_to :session
  belongs_to :custom_agent
end
