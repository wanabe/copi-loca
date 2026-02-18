class AddExecutionTimingToOperations < ActiveRecord::Migration[8.1]
  def change
    # Add an enum-like column for execution timing. Using integer for enum compatibility.
    add_column :operations, :execution_timing, :integer, null: false, default: 1
  end
end
