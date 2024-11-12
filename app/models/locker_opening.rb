class LockerOpening < ApplicationRecord

  belongs_to :locker, class_name: "Locker"

  validates :locker_id, presence: { message: "of locker opening must be present" }

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

end