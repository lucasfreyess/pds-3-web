class AddReferencesToControllers < ActiveRecord::Migration[7.2]
  def change
    add_reference :controllers, :user, foreign_key: {to_table: :users}
    #add_reference :controllers, :model, foreign_key: {to_table: :models}
    # es mejor que user posea un modelo
  end
end
