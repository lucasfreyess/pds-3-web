class AddReferencesToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :model, foreign_key: {to_table: :models}
  end
end
