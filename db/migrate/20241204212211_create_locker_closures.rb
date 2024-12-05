class CreateLockerClosures < ActiveRecord::Migration[7.2]
  def change
    create_table :locker_closures do |t|

      t.references :locker, null: false, foreign_key: true
      t.references :locker_opening, null: false, foreign_key: true
      t.datetime :closed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :was_succesful, null: false, default: false

      t.timestamps
    end
  end
end
