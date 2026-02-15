class AddRpcMessageToMessage < ActiveRecord::Migration[8.1]
  def change
    add_reference :messages, :rpc_message, null: false, foreign_key: true
  end
end
