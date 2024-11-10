class CreateLockers < ActiveRecord::Migration[7.2]
  def change
    create_table :lockers do |t|

      t.string :name, null: false, default: "" #el nombre que va a ver el usuario
      t.string :description, null: false, default: "" #la descripcion que va a ver el usuario
      t.string :owner_email, null: false, default: ""
      t.string :password, array: true, default: [], null: false #la contrasena es un array de los names de los 4 gestos que la conforman 
      t.boolean :is_locked, null: false, default: true
      t.datetime :last_opened_at
      t.string :esp32_id #la vd es q no creo q el espwroom le asignara un id pero pico
      t.integer :open_count, null: false, default: 0

      t.timestamps
    end
  end
end
