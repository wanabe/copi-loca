class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :session, type: :string, null: false, foreign_key: false
      t.references :rpc_log, null: false, foreign_key: false
      t.integer :direction, null: false, default: 1
      t.string :content, null: false

      t.timestamps
    end
  end
end
