class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.string :name, :default => ""
      t.string :surname, :default => ""
      t.string :phone, :default => "+39"
      t.string :shared_pwd, :default => ""
      t.boolean :admin, :default => false

      t.string :username
      t.string :code
      t.time :last_code_sent
      t.boolean :activated, :default => false

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
  end
end
