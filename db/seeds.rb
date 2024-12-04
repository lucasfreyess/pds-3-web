# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

LockerOpening.delete_all
Locker.delete_all
Gesture.delete_all
Controller.delete_all
User.delete_all
Model.delete_all

modelo_1 = Model.create!(
  name: 'Modelo del Proyecto',
  description: 'Model 1 description'
)

modelo_2 = Model.create!(
  name: 'Modelo de prueba',
  description: 'Model 2 description'
)

controller_1 = Controller.create!(
  name: 'Controlador de prueba.. no pescar...',
  esp32_mac_address: '00:00:00:00:00:01',
)

controller_3 = Controller.create!(
  name: 'ESP',
  esp32_mac_address: 'ccdba7563174',
)

4.times do |i|

  Locker.create!(
    name: "Locker #{i+1}",
    description: "Locker #{i+1} description",
    controller: controller_1
  )

end

# lockers de controlador ESP
3.times do |i|

  Locker.create!(
    name: "#{i+1}",
    description: "Locker #{i+1} description",
    controller: controller_3
  )

end

# no incluye la generacion de blank ni del gesto 7
5.times do |i|

  gesture = Gesture.create!(
    name: "Gesture #{i+1}",
    description: "En Controlador fisico es: #{i}",
    model: modelo_1
  )

  gesture.image.attach(io: File.open(Rails.root.join("app/assets/images/#{i + 1}.png")), filename: "#{i + 1}.png", content_type: 'image/png')
end

blank = Gesture.create!(
  name: "Blank",
  description: "En Controlador fisico es: 6",
  model: modelo_1
)
blank.image.attach(io: File.open(Rails.root.join('app/assets/images/blank.png')), filename: "blank.png", content_type: 'image/png')

seven = Gesture.create!(
  name: "Gesture 7",
  description: "En Controlador fisico es: 7",
  model: modelo_1
)
seven.image.attach(io: File.open(Rails.root.join('app/assets/images/7.png')), filename: "7.png", content_type: 'image/png')

8.times do |i|

  Gesture.create!(
    name: "Gesture #{i+8}",
    description: "Gesture #{i+8} description",
    model: modelo_2
  )

end

# locker openings de prueba
LockerOpening.create!(
  locker: Locker.last, #del controlador ESP
  opened_at: Time.now - 30.seconds,
  closed_at: Time.now,
  was_succesful: true
)

LockerOpening.create!(
  locker: Locker.last, #del controlador ESP
  opened_at: Time.now - 90.seconds,
  closed_at: Time.now,
  was_succesful: false
)

puts 'Seed finished!!'