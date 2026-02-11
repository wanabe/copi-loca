class RpcLog < ApplicationRecord
  belongs_to :session, optional: false
  has_one :message, required: false

  enum :direction, { outgoing: 1, incoming: 2 }
end
