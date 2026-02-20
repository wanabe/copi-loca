class AddNameToTools < ActiveRecord::Migration[8.1]
  def change
    add_column :tools, :name, :string
  end
end
