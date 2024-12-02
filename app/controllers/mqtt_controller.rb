# app/controllers/mqtt_controller.rb
class MqttController < ApplicationController
    def send_message
      # Dirección IP del broker remoto o dominio
      broker_ip = "test.mosquitto.org"

      # Conexión al broker
      # client = MQTT::Client.new(:host => "mqtt://#{broker_ip}", :port => 1883)
      client = MQTT::Client.new
      client.host = broker_ip  # Dirección IP del broker
      client.port = 1883
      # client.ssl = true

      # Conéctate al broker
      client.connect

      # Publica un mensaje en un tópico específico
      client.publish('esp32/topic', 'Mensaje desde Rails')

      # Desconéctate del broker
      client.disconnect

      render json: { message: 'Mensaje enviado a MQTT' }
    end

    def subscribe_to_status

      # Dirección IP del broker remoto o dominio
      broker_ip = "test.mosquitto.org"

      # Conéctate al broker
      client = MQTT::Client.new
      client.host = broker_ip
      client.port = 1883
      client.connect

      # Suscríbete al tópico y define el comportamiento cuando se reciba un mensaje
      client.get('controladores/status') do |topic, message|
        Rails.logger.info "Mensaje recibido en el tópico #{topic}: #{message}"

        data = JSON.parse(message)
        last_connected_at = Time.parse(data["time"])  # Almacenar el tiempo de la última conexión
        controller = Controller.find_by(esp32_mac_address: data["controller_id"])
        if controller
          controller.update(last_connected_at: last_connected_at)
        else
          Rails.logger.warn "Controlador no encontrado para ID: #{data["controller_id"]}"
        end
      end

      # Desconéctate después de recibir el mensaje
      client.disconnect

      render json: { message: 'Escuchando los mensajes en el tópico' }
    end

    def send_keys
      # Cargar el controlador por su ID
      @controller = Controller.find_by(id: params[:controller_id])

      # Log para verificar el ID del controlador
      Rails.logger.info("ID CONTROLLER: #{params[:controller_id]}")

      # Verificar si el controlador existe
      if @controller.nil?
        Rails.logger.error("Controlador no encontrado para ID: #{params[:controller_id]}")
        return render json: { error: "Controlador no encontrado" }, status: :not_found
      end

      # Dirección IP del broker remoto o dominio
      broker_ip = "test.mosquitto.org"

      # Recuperar las claves de los lockers asociados al controlador
      claves = @controller.lockers.map(&:password)  # Suponemos que cada locker tiene una propiedad `password`

      # Log para verificar las claves de los lockers
      Rails.logger.info("Claves de los lockers: #{claves.inspect}")

      time_now = Time.now.to_s

      # JSON con las claves y la hora
      message = {
        claves: claves,
        time: time_now
      }.to_json

      # Conexión al broker MQTT
      client = MQTT::Client.new
      client.host = broker_ip  # Dirección IP del broker
      client.port = 1883

      # Log para verificar conexión con el broker
      Rails.logger.info("Conectando al broker MQTT en #{broker_ip}:1883")

      # Conéctate al broker
      client.connect

      # Log para verificar el tópico y el mensaje a publicar
      topic = params[:topic] || "controlador/#{@controller.esp32_mac_address}"  # Usar el ID del en el topic si no se pasa uno
      Rails.logger.info("Publicando mensaje en el tópico: #{topic} con mensaje: #{message}")

      # Publica el mensaje en un tópico específico
      client.publish(topic, message)

      # Desconéctate del broker
      client.disconnect

      # Log para confirmar que el mensaje fue enviado
      Rails.logger.info("Mensaje enviado al MQTT")

      # Responder con un mensaje de éxito
      render json: { message: 'Mensaje enviado al MQTT', data: message }
    end

    def publish_controller_register(controller)
      message = {
        time: Time.now.to_s, # timestamp actual
        lockers: controller.lockers.count, #cantidad de lockers
      }.to_json

      # Configuraciones
      broker_ip = "test.mosquitto.org"  # Dirección del broker MQTT
      topic = "registrar/#{controller.esp32_mac_address}"  # El tópico con la dirección MAC

      client = MQTT::Client.new
      client.host = broker_ip  # Dirección del broker
      client.port = 1883       # Puerto MQTT

      # Conecta al broker MQTT y publica el mensaje
      begin
        client.connect
        client.publish(topic, message)
        client.disconnect
      rescue => e
        Rails.logger.error "Error al publicar mensaje MQTT: #{e.message}"
      end
    end


  end
