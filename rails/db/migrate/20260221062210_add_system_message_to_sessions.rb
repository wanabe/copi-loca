class AddSystemMessageToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :system_message_mode, :integer, default: 0, null: false
    add_column :sessions, :system_message, :text
  end
end
