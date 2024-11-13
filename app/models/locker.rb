class Locker < ApplicationRecord

  belongs_to :controller, class_name: "Controller"  
  has_many :locker_openings, class_name: "LockerOpening", dependent: :destroy
  
  before_create :check_locker_limit, :increment_locker_count
  after_update :send_locker_update_email, if: :owner_or_password_changed?
  
  # el locker viene asociado a un controlador por defecto, por lo que
  # una contraseña deberia ser creada cuando se asocia un usuario al
  # controlador, y un modelo al usuario xdd
  #before_create :check_password_length

  #validates :owner_email, presence: { message: "of locker must be present" }
  #validates :is_locked, presence: { message: "of locker must be provided" }
  #validates :open_count, presence: {message: "of locker must be present"}
  validates :controller_id, presence: {message: "of locker must be present"}
  
  #validate :complete_gesture_set_if_any

  validate :print_errors

  def print_errors
    puts errors.full_messages
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
    saved_change_to_owner_email? || saved_change_to_password?
  end

  def send_locker_update_email
    puts "ENVIANDO EMAIL!!......"
    LockerMailer.locker_update_notification(self).deliver_now
  end

  # Valida que si se modifica un gesto, se modifiquen los cuatro
  #def complete_gesture_set_if_any
  #  gestures = [gesture_1, gesture_2, gesture_3, gesture_4]
  #  if gestures.any?(&:present?) && gestures.any?(&:blank?)
  #    errors.add(:base, "Si modifica un gesto, debe modificar los cuatro.")
  #  end
  #end

end