class CreateCustomAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_agents do |t|
      t.string :name
      t.string :display_name
      t.text :description
      t.text :prompt

      t.timestamps
    end
  end
end
