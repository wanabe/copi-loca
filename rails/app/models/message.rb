class Message < ApplicationRecord
  belongs_to :session, optional: false
  belongs_to :rpc_log, optional: false

  enum :direction, { outgoing: 1, incoming: 2 }
end
