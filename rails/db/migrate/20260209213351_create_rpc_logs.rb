class CreateRpcLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :rpc_logs do |t|
      t.references :session, type: :string, null: false, foreign_key: false
      t.string :rpc_id, null: true
      t.integer :direction, null: false, default: 1
      t.json :data, null: false

      t.timestamps
    end
  end
end
