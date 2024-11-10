class Locker < ApplicationRecord

  belongs_to :controller, class_name: "Controller"  
  
  before_create :check_locker_limit, :increment_locker_count
  
  # el locker viene asociado a un controlador por defecto, por lo que
  # una contraseña deberia ser creada cuando se asocia un usuario al
  # controlador, y un modelo al usuario xdd
  #before_create :check_password_length

  #validates :owner_email, presence: { message: "of locker must be present" }
  #validates :is_locked, presence: { message: "of locker must be provided" }
  #validates :open_count, presence: {message: "of locker must be present"}
  validates :controller_id, presence: {message: "of locker must be present"}
  
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

end