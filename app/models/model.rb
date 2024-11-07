class Model < ApplicationRecord

  has_many :controllers, class_name: "Controller"

end