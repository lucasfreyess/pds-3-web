class LockerOpening < ApplicationRecord

  belongs_to :locker, class_name: "Locker"

  after_create :send_locker_opening_email
  
  validates :locker_id, presence: { message: "of locker opening must be present" }

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  private

  def send_locker_opening_email
    puts "ENVIANDO EMAIL DE APERTURA DE CASILLERO..."
    LockerMailer.locker_opening_notification(self.locker).deliver_later
  end

end