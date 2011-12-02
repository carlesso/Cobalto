class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.integer :user_id
      t.string :phone
      t.string :content
      t.boolean :processed, :default => false
      t.string :callback_result

      t.timestamps
    end
  end
end
