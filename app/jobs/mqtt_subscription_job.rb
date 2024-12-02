class MqttSubscriptionJob < ApplicationJob
  queue_as :default

  def perform
    broker_ip = "test.mosquitto.org"  # Dirección IP del broker MQTT
    client = MQTT::Client.new
    client.host = broker_ip
    client.port = 1883
    client.connect

    # Suscripción al tópico 'controladores/status'
    client.get('controladores/status') do |topic, message|
      Rails.logger.info "Mensaje recibido en el tópico #{topic}: #{message}"

      # Convertir el mensaje JSON en un hash
      data = JSON.parse(message)

      # Extraer el tiempo de la última conexión desde el mensaje
      last_connected_at = Time.parse(data["time"])

      # Encontrar el controlador asociado utilizando el controller_id
      controller = Controller.find_by(esp32_mac_address: data["controller_id"])

      if controller
        # Actualizar el campo last_connected_at con la nueva hora
        controller.update(last_connected_at: last_connected_at)
      else
        Rails.logger.warn "Controlador no encontrado para ID: #{data["controller_id"]}"
      end
    end

    # Desconectar del broker
    client.disconnect
  end
end
