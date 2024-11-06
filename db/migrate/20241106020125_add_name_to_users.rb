class AddNameToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users do |t|
      t.string :name, null: false, default: ""
      t.boolean :is_admin, null: false, default: false
    end
  end
end
