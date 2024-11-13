class AddWasSuccesfulToLockerOpenings < ActiveRecord::Migration[7.2]
  def change
    add_column :locker_openings, :was_succesful, :boolean, default: false
  end
end
