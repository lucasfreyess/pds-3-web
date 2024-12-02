class AddLastClosedAtToLockers < ActiveRecord::Migration[7.2]
  def change
    add_column :lockers, :last_closed_at, :datetime#, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
