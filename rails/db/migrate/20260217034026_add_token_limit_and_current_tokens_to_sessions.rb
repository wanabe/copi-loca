class AddTokenLimitAndCurrentTokensToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :token_limit, :integer
    add_column :sessions, :current_tokens, :integer
  end
end
