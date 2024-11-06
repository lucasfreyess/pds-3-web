class Gesture < ApplicationRecord

  belongs_to :model
  has_one_attached :image 
  # yo creo que lo mejor seria que el superusuario pueda subir la imagen desde la pagina
  #,,, no es necesario que se vea bonito

end