class Message < ApplicationRecord
  belongs_to :session, optional: false
  belongs_to :rpc_log, optional: false

  enum :direction, { outgoing: 1, incoming: 2 }

  before_validation :assign_rpc_log, on: :create, if: -> { outgoing? }


  def assign_rpc_log
    return if content.blank?
    session.send_prompt(content)
    rpc_log = session.rpc_logs.build(direction: :outgoing, data: {})
    self.rpc_log = rpc_log
  end
end
