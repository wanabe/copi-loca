class AddSkillDirectoryPatternToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :skill_directory_pattern, :string
  end
end
