class Locker < ApplicationRecord

  belongs_to :controller, class_name: "Controller"  

end