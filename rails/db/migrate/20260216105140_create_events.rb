class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :event_id, null: false
      t.references :session, type: :string, null: false, foreign_key: false
      t.references :rpc_message, null: true, foreign_key: false
      t.string :event_type
      t.json :data
      t.timestamp :timestamp
      t.references :parent_event, null: true, foreign_key: false
      t.boolean :ephemeral

      t.timestamps
    end
  end
end
