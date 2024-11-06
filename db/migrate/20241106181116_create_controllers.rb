class CreateControllers < ActiveRecord::Migration[7.2]
  def change
    create_table :controllers do |t|
      
      t.string :name, null: false, default: ""
      t.string :esp32_mac_address, null: false
      t.datetime :last_seen_at, default: -> { 'CURRENT_TIMESTAMP' }
      
      t.timestamps
    end
  end
end
