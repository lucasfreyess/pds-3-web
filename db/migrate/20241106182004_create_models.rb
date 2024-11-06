class CreateModels < ActiveRecord::Migration[7.2]
  def change
    create_table :models do |t|
      
      t.string :name, null: false, default: ""
      t.string :description, null: false, default: ""
      t.string :url, null: false, default: ""
      t.string :version, null: false, default: ""

      t.timestamps
    end
  end
end
