class CreateSessionCustomAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :session_custom_agents do |t|
      t.references :session, null: false, foreign_key: false
      t.references :custom_agent, null: false, foreign_key: false

      t.timestamps
    end
  end
end
