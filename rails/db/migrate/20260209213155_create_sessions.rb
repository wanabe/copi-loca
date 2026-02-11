class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions, id: :string do |t|
      t.string :model, null: false

      t.timestamps
    end
  end
end
