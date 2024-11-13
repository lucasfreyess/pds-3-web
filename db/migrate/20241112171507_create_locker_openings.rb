class CreateLockerOpenings < ActiveRecord::Migration[7.2]
  def change
    create_table :locker_openings do |t|
      
      t.references :locker, null: false, foreign_key: true
      t.datetime :opened_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      #t.boolean :was_succesful, null: false, default: true

      t.timestamps
    end
  end
end
