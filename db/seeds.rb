# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Model.delete_all
Controller.delete_all
Locker.delete_all
User.delete_all

modelo_1 = Model.create!(
  name: 'Model 1',
  description: 'Model 1 description'
)

user_1 = User.create!(
  name: 'Admin',
  email: 'lucas@gmail.com',
  password: '123456',
  is_admin: true,
  model: modelo_1
)

controller_1 = Controller.create!(
  name: 'Controller 1', 
  esp32_mac_address: '00:00:00:00:00:01',
  user: user_1
)

4.times do |i|

  Locker.create!(
    name: "Locker #{i+1}",
    description: "Locker #{i+1} description",
    controller: controller_1
  )

end

7.times do |i|

  Gesture.create!(
    name: "Gesture #{i+1}",
    description: "Gesture #{i+1} description",
    model: modelo_1
  )

end

puts 'Seed finished!!'