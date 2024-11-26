class LockerOpening < ApplicationRecord

  belongs_to :locker, class_name: "Locker"

  before_create :increment_locker_open_count
  after_create :set_locker_last_opened_at
  after_create :send_locker_opening_email
  
  validates :locker_id, presence: { message: "of locker opening must be present" }

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  private

  def send_locker_opening_email
    LockerMailer.locker_opening_notification(self.locker).deliver_later
  end

  def increment_locker_open_count
    locker.increment!(:open_count)
  end

  def set_locker_last_opened_at
    puts "#############Setting last_opened_at to #{self.opened_at}"
    locker.update!(last_opened_at: self.opened_at)
  end
end