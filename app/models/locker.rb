class Locker < ApplicationRecord

  belongs_to :controller, class_name: "Controller", dependent: :destroy
  has_many :locker_openings, class_name: "LockerOpening", dependent: :destroy

  # before_create :check_locker_limit
  before_create :increment_locker_count
  after_update :send_locker_update_email, if: :owner_or_password_changed?

  # el locker viene asociado a un controlador por defecto, por lo que
  # una contraseña deberia ser creada cuando se asocia un usuario al
  # controlador, y un modelo al usuario xdd

  validates :controller_id, presence: {message: "of locker must be present"}

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  # Checks if the locker is active based on the last time it was opened.
  # A locker is considered active if it was opened within the last 10 minutes.
  #
  # @return [Boolean] true if the locker was opened within the last 10 minutes, false otherwise.
  # @example
  #   locker.last_opened_at = Time.now - 5.minutes
  #   locker.is_active # => true
  #   locker.last_opened_at = Time.now - 15.minutes
  #   locker.is_active # => false
  def is_active

    if self.last_opened_at.nil?
      return false
    end

    return self.last_opened_at >= 10.minutes.ago
  end

  private

  def check_locker_limit
    if controller.locker_count >= 4
      errors.add(:base, "Este controlador ya tiene el máximo de 4 casilleros.")
      throw(:abort)  # Cancela la creación del Locker
    end
  end

  # Incrementa el locker_count en el controller correspondiente
  def increment_locker_count
    controller.increment!(:locker_count)
  end

  def check_password_length
    if password.length != 4
      errors.add(:password, "La contraseña debe tener 4 caracteres.")
      throw(:abort)
    end
  end

  def owner_or_password_changed?
    puts "CHECKEANDO SI CAMBIO EL OWNER O LA CONTRASEÑA..."
    return false if self.controller.user_id.nil?
    saved_change_to_owner_email? || saved_change_to_password?
  end

  def send_locker_update_email
    puts "ENVIANDO EMAIL!!......"
    LockerMailer.locker_update_notification(self).deliver_later
  end

end
