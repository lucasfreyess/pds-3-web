class CreateGestures < ActiveRecord::Migration[7.2]
  def change
    create_table :gestures do |t|
      
      t.string :name, null: false, default: ""
      t.string :description, default: ""
      
      t.timestamps
    end
  end
end
