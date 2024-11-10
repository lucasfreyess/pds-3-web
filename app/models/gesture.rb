class Gesture < ApplicationRecord

  belongs_to :model
  has_one_attached :image 
  # yo creo que lo mejor seria que el superusuario pueda subir la imagen desde la pagina
  #,,, no es necesario que se vea bonito

  validates :name, presence: { message: "of Gesture must be provided" }
  #validates :description, presence: { message: "of Gesture must be at least Blank" }
  validates :model_id, presence: { message: "of Gesture must be present" }
  
  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

end