class CreateOperations < ActiveRecord::Migration[8.1]
  def change
    create_table :operations do |t|
      t.string :command
      t.string :directory

      t.timestamps
    end
  end
end
