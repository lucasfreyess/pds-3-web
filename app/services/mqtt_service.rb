class MqttService

  # metodo para procesar mensajes de estado de controladores
  # desde el topic de status del broker MQTT!!
  def self.process_status_message(payload)

    data = JSON.parse(payload)

    esp32_mac_address = data['esp32_mac_address']
    lockers_passwords = data['lockers_passwords']
    lockers_status = data['lockers_status']
    timestamp = Time.parse(data['timestamp']) #ermmm
    model_url = data['model_url']
    model_version = data['model_version'] #este atributo probablemente no vaya xd

    controller = Controller.find_by(esp32_mac_address: esp32_mac_address)
    model = Model.find_by(url: model_url)

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

    model.update!(
      url: model_url
      version: model_version, # sacar esto si es que no ponemos version al modelo
    ) if model

    Rails.logger.info "Estado del controlador #{esp32_mac_address} actualizado exitosamente."

  end

  # metodo para crear LockerOpenings desde mensajes de apertura
  # de casilleros desde el topic de openings del broker MQTT!!
  def self.process_locker_opening_message(payload)
      
    data = JSON.parse(payload)

    esp32_mac_address = data['esp32_mac_address']
    # probablemente deberia hacer que locker.name sea unico dentro de un controlador
    locker_name = data['locker_name']
    timestamp = Time.parse(data['timestamp'])

    controller = Controller.find_by(esp32_mac_address: esp32_mac_address)
    locker = Locker.find_by(controller: controller, password: locker_password)

    unless controller
      Rails.logger.error "Controller with MAC address #{esp32_mac_address} not found. Aborting locker_opening message processing."
      return
    end

    unless locker
      Rails.logger.error "Locker with password #{locker_password} not found. Aborting locker_opening message processing."
      return
    end

    locker_opening = LockerOpening.create!(
      locker: locker,
      opened_at: timestamp
    )

    Rails.logger.info "Apertura de casillero #{locker_password} registrada exitosamente."

  end
end

