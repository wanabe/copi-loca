class CreateSessionTools < ActiveRecord::Migration[8.1]
  def change
    create_table :session_tools do |t|
      t.references :session, type: :string, null: false, foreign_key: false
      t.references :tool, null: false, foreign_key: false

      t.timestamps
    end
  end
end
