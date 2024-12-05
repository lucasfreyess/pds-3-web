class LockerClosure < ApplicationRecord
  belongs_to :locker
  belongs_to :locker_opening

  after_create :set_locker_last_closed_at

  validates :locker_id, presence: { message: "of locker closure must be present" }
  validates :locker_opening_id, presence: { message: "of locker closure must be present" }

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end
  
  private

  def set_locker_last_closed_at
    puts "#############Setting last_closed_at to #{self.closed_at}"
    locker.update!(last_closed_at: self.closed_at)
  end
end