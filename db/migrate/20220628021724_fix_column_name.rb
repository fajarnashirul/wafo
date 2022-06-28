class FixColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :reset_password_token, :reset_token
    rename_column :users, :reset_password_sent_at, :reset_token_sent_at
  end
end
