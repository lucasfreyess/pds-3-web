class MqttService
  BROKER_URL = 'test.mosquitto.org'

  def self.start
    Thread.new do
      loop do
        begin
          MQTT::Client.connect(host: BROKER_URL, port: 1883, keep_alive: 60) do |client|
            topic = "controladores/+/locker_+/status"
            client.subscribe(topic)

            puts "Suscrito al topic #{topic}"
            
            client.get do |topic, message|
              begin
                process_message(topic, message)
              rescue StandardError => e
                Rails.logger.error "Error al procesar mensaje MQTT: #{e.message}"
              end
            end
          end
        rescue MQTT::ProtocolException => e
          Rails.logger.error "MQTT::ProtocolException: #{e.message}. Reintentando en 5 segundos..."
          sleep(5) # Espera antes de intentar reconectar
          retry
        rescue StandardError => e
          Rails.logger.error "Error en MQTT: #{e.message}"
          sleep(5)
          retry
        end
      end
    end
  end
  # metodo para procesar mensajes de estado de controladores
  # desde el topic de status del broker MQTT!!
  def self.process_status_message(payload)

    data = JSON.parse(payload)

    esp32_mac_address = data['esp32_mac_address']
    # lockers_passwords = data['lockers_passwords']
    # lockers_status = data['lockers_status']
    timestamp = Time.parse(data['timestamp']) #ermmm
    # model_url = data['model_url']
    # model_version = data['model_version'] #este atributo probablemente no vaya xd

    controller = Controller.find_by(esp32_mac_address: esp32_mac_address)
    # model = Model.find_by(url: model_url)

    unless controller
      Rails.logger.error "Controller with MAC address #{esp32_mac_address} not found. Aborting message processing."
      return
    end

    # creo que es mas barato actualizar de a una, en vez de checkear si
    # los datos entregados son distintos a los actuales

    controller.update!(last_seen_at: timestamp) # el mac address no deberia cambiar!!

    controller.lockers.each_with_index do |locker, index|
      locker.update!(
        password: lockers_passwords[index], 
        is_locked: lockers_status[index]
      )
    end

    # model.update!(
    #   url: model_url
    #   version: model_version, # sacar esto si es que no ponemos version al modelo
    # ) if model

    Rails.logger.info "Estado del controlador #{esp32_mac_address} actualizado exitosamente."

  end

  def self.process_message(topic, message)
    payload = JSON.parse(message)
    if topic.include?("status")
      process_locker_opening_message(payload)
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Error al parsear JSON: #{e.message}"
  end

  # metodo para crear LockerOpenings desde mensajes de apertura
  # de casilleros desde el topic de openings del broker MQTT!!
  def self.process_locker_opening_message(payload)
    esp32_mac_address = payload['esp32_mac_address']
    locker_name = payload['locker_id']
    timestamp = Time.parse(payload['time'])
    status = payload['status']

    controller = Controller.find_by(esp32_mac_address: esp32_mac_address)
    locker = controller&.lockers&.find_by(name: locker_name)

    unless controller && locker
      Rails.logger.error "Controller o Locker no encontrados para el mensaje recibido."
      return
    end

    if status == "abierto"
      LockerOpening.create!(locker: locker, opened_at: timestamp)
      Rails.logger.info "Apertura de casillero #{locker_name} registrada exitosamente."
    else
      Rails.logger.info "Estado recibido no es de apertura: #{status}"
    end
  end
end

