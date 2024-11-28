class Gesture < ApplicationRecord

  belongs_to :model
  has_one_attached :image 
  # yo creo que lo mejor seria que el superusuario pueda subir la imagen desde la pagina
  #,,, no es necesario que se vea bonito

  before_create :increment_gesture_count

  validates :name, presence: { message: "of Gesture must be provided" }
  validates :description, presence: { message: "of Gesture must be at least Blank" }, on: :update
  
  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  private

  def increment_gesture_count
    model.increment!(:gesture_count)
  end

end