class MqttService
  BROKER_URL = 'test.mosquitto.org'

  def self.start
    Thread.new do
      loop do
        begin
          MQTT::Client.connect(host: BROKER_URL, port: 1883, keep_alive: 60) do |client|
            topic = "controladores/locker/status"
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
    Rails.logger.info "Mensaje recibido: #{payload}"
    Rails.logger.info "Tipo de dato del payload: #{payload.class}"
    data = payload.is_a?(String) ? JSON.parse(payload) : payload

    esp32_mac_address = data['controller_id']
    statuses = data['status']      # Estado actual de cada casillero
    changes = data['changed']      # Índices que indican los casilleros que cambiaron
    timestamp = Time.parse(data['time'])

    controller = Controller.find_by(esp32_mac_address: esp32_mac_address)
    # model = Model.find_by(url: model_url)

    unless controller
      Rails.logger.error "Controller with MAC address #{esp32_mac_address} not found. Aborting message processing."
      return
    end

    # creo que es mas barato actualizar de a una, en vez de checkear si
    # los datos entregados son distintos a los actuales

    controller.update!(last_seen_at: timestamp) # el mac address no deberia cambiar!!

     changes.each_with_index do |changed, index|
      next unless changed == 1  # Solo procesa casilleros que cambiaron (indicado con 1)

      locker = controller.lockers[index]
      next unless locker  # Si no se encuentra el casillero, omite

      # Actualiza el estado del casillero en la base de datos
      locker.update!(is_locked: statuses[index] == 0)

      # Llama a `process_locker_opening_message` para registrar la apertura
      process_locker_opening_message({
        'esp32_mac_address' => esp32_mac_address,
        'locker_id' => locker.name,
        'time' => timestamp.iso8601,
        'status' => statuses[index] == 0 ? 'cerrado' : 'abierto'
      })
    end

    Rails.logger.info "Estado del controlador #{esp32_mac_address} y casilleros actualizado exitosamente."
  end

  def self.process_message(topic, message)
    # Convierte `message` en hash si no lo es
    payload = message.is_a?(String) ? JSON.parse(message) : message

    if topic.include?("status")
      process_status_message(payload)
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

