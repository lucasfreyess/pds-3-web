class RemoveClosedAtFromLockersOpenings < ActiveRecord::Migration[7.2]
  def change
    remove_column :locker_openings, :closed_at, :datetime
  end
end
