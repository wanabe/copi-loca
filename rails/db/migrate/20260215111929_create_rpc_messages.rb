class CreateRpcMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :rpc_messages do |t|
      t.references :session, type: :string, null: false, foreign_key: false
      t.integer :direction, null: false, default: 1
      t.integer :message_type, null: false, default: 1
      t.string :rpc_id
      t.string :method
      t.json :params
      t.json :result
      t.json :error

      t.timestamps
    end
  end
end
