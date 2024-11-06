class AddReferencesToGestures < ActiveRecord::Migration[7.2]
  def change
    add_reference :gestures, :model, null: false, foreign_key: { to_table: :models}
  end
end
