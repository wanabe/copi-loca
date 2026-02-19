class CreateToolParameters < ActiveRecord::Migration[8.1]
  def change
    create_table :tool_parameters do |t|
      t.references :tool, null: false, foreign_key: false
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
