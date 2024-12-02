class AddClosuresToLockerOpenings < ActiveRecord::Migration[7.2]
  def change
    add_column :locker_openings, :closed_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    # no creo que sea necesario añadir un was_closed_succesfully pq ya mucho..
  end
end
