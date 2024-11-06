class CreateLockers < ActiveRecord::Migration[7.2]
  def change
    create_table :lockers do |t|

      t.string :owner_email, null: false, default: ""
      t.integer :password, array: true, default: [] #la contrasena es un array de los ids de los 4 gestos que la conforman 
      t.boolean :is_locked, null: false, default: true
      t.datetime :last_opened_at
      t.string :esp32_id #la vd es q no creo q el espwroom le asignara un id pero pico
      t.integer :open_count, null: false, default: 0

      t.timestamps
    end
  end
end
