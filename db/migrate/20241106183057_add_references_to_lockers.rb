class AddReferencesToLockers < ActiveRecord::Migration[7.2]
  def change
    add_reference :lockers, :controller, null: false, foreign_key: { to_table: :controllers}
  end
end
