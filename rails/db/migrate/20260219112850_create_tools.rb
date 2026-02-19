class CreateTools < ActiveRecord::Migration[8.1]
  def change
    create_table :tools do |t|
      t.string :description
      t.text :script

      t.timestamps
    end
  end
end
