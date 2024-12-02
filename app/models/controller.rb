class Controller < ApplicationRecord

  belongs_to :user, optional: true
  has_many :lockers, class_name: "Locker", dependent: :destroy
  # accepts_nested_attributes_for :lockers #para el form de new_controller

  validates :name, presence: { message: "Name can't be blank" }
  #validates :esp32_mac_address, presence: { message: "ESP32 MAC Address can't be blank" }
  #validates :last_seen_at, presence: { message: "must be provided.."}
  #validates :user_id, presence: { message: "of owner must be present"}
  #validates :model_id, presence: { message: "of controller must be present"}

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  # regenera automáticamente las claves de todos los casilleros si el modelo cambia
  def regenerate_lockers_passwords_if_model_changed

    return unless user.model.present? #si el usuario no tiene modelo, no se puede cambiar las claves xd

    lockers.each do |locker|
      gestures = user.model.gestures.sample(4) #creo q esto se puede hacer si es que hice los modelos bien!
      locker.update(password: gestures.map(&:name))
    end

    # lo siguiente no va a funcionar todavia pq MQTT_CLIENT no esta definido
    #publish_lockers_passwords
    MqttController.send_keys_after_model_update(self)
  end

  # para mqtt!!
  def publish_lockers_passwords
    passwords = lockers.order(:id).pluck(:password)
    # se podria cambiar la estructura de passwords para incluir el id del locker y quizas los ids/nombres de los gestos
    payload = {
      esp32_mac_address: esp32_mac_address,
      passwords: passwords,
      model_url: controller.user.model.model_url
    }.to_json

    MQTT_CLIENT.publish(MQTT_TOPIC_PASSWORDS, payload)
  end

  # determina si el controlador esta activo
  def is_active
    self.last_seen_at >= 10.minutes.ago
  end

end
