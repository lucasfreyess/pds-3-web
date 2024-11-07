class Controller < ApplicationRecord

  belongs_to :user
  belongs_to :model
  has_many :lockers, class_name: "Locker"

end