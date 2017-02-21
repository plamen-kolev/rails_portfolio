class AddAdminToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin, :boolean, default:false

    add_column :admins, :failed_attempts, :integer, default: 0
    add_column :admins, :unlock_token, :string # Only if unlock strategy is :email or :both
    add_column :admins, :locked_at, :datetime
  end
end
