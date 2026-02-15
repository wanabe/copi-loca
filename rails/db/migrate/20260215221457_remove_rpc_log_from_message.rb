class RemoveRpcLogFromMessage < ActiveRecord::Migration[8.1]
  def change
    remove_reference :messages, :rpc_log, null: false, foreign_key: false
  end
end
