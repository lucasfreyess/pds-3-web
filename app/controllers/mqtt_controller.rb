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

    def self.send_keys_after_model_update(controller)
      return { success: false, error: "Controlador no encontrado" } if controller.nil?
  
      broker_ip = "test.mosquitto.org"
      port = 1883

      claves = controller.lockers.map(&:password)
      time_now = Time.now.to_s
  
      message = {
        claves: claves,
        time: time_now
      }.to_json
  
      client = MQTT::Client.new(host: broker_ip, port: port)
  
      Rails.logger.info("LLAMADA A SEND_KEYS_AFTER_MODEL_UPDATE OLAAAAAAAAAAAAAAaa")

      begin
        client.connect
        topic = "controlador/#{controller.esp32_mac_address}"
        Rails.logger.info("Publicando mensaje en el tópico: #{topic} con mensaje: #{message}")
        client.publish(topic, message)
        client.disconnect
        { success: true }
      rescue => e
        Rails.logger.error "Error al publicar mensaje MQTT: #{e.message}"
        { success: false, error: e.message }
      end
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

    def connection(controller)
      message = {
        time: Time.now.to_s, # timestamp actual
        sender: "WEB"
        # lockers: controller.lockers.count, #cantidad de lockers
      }.to_json

      broker_ip = "test.mosquitto.org"  # Dirección del broker MQTT
      topic = "#{controller.esp32_mac_address}"

      client = MQTT::Client.new
      client.host = broker_ip  # Dirección del broker
      client.port = 1883       # Puerto MQTT

      Rails.logger.debug "Preparando para enviar mensaje al controlador #{controller.id} en el topic #{topic}: #{message}"
      # Conecta al broker MQTT y publica el mensaje
      begin
        client.connect
        Rails.logger.debug "Conexión exitosa al broker MQTT en #{broker_ip}."
        client.publish(topic, message)
        Rails.logger.debug "Mensaje enviado exitosamente al topic #{topic}: #{message}"
        client.disconnect
    def send_model_update(model)
      Rails.logger.info("Recibiendo petición para enviar el modelo nuevo a los controladores")
      # Cargar el modelo por su ID
      #@model = Model.find_by(id: params[:model_id])

      # Log para verificar el ID del modelo
      Rails.logger.info("ID MODEL: #{model.id}")

      # Verificar si el modelo existe
      if model.nil?
        Rails.logger.error("Modelo no encontrado para ID: #{model.id}")
        return render json: { error: "Modelo no encontrado" }, status: :not_found
      end

      # Dirección IP del broker remoto o dominio
      broker_ip = "test.mosquitto.org"

      # JSON con las claves y la hora
      message = {
        model_url: model.url,
        #gestures_names: @model.gestures.pluck(:name),
        time: Time.now.to_s
      }.to_json

      # Conexión al broker MQTT
      client = MQTT::Client.new
      client.host = broker_ip  # Dirección IP del broker
      client.port = 1883

      # Log para verificar conexión con el broker
      Rails.logger.info("Conectando al broker MQTT en #{broker_ip}:1883")

      begin
        # Conéctate al broker
        client.connect


        # Log para verificar el tópico y el mensaje a publicar
        #topic = params[:topic] || "modelo/#{params[:model_id]}"  # Usar el ID del en el topic si no se pasa uno
        
        model.users.each do |user|
          user.controllers.each do |controller|
            topic = "controller/#{controller.esp32_mac_address}/new_model"
            Rails.logger.info("Publicando mensaje en el tópico: #{topic} con mensaje: #{message}")
            client.publish(topic, message)
          end
        end

        # Desconéctate del broker
        client.disconnect

        # Log para confirmar que el mensaje fue enviado
        Rails.logger.info("Mensajes enviados al MQTT")

        # Responder con un mensaje de éxito
        #render json: { message: 'Mensaje enviado al MQTT', data: message }
      rescue => e
        Rails.logger.error "Error al publicar mensaje MQTT: #{e.message}"
      end
    end
<<<<<<< HEAD

    def subscribe_to_controller_connection(controller)
      if controller.nil?
        render json: { error: "Controlador no encontrado para el ID #{controller_id}" }, status: :not_found
        return
      end
    
      # Dirección IP del broker remoto o dominio
      broker_ip = "test.mosquitto.org"
    
      # Conéctate al broker
      client = MQTT::Client.new
      client.host = broker_ip
      client.port = 1883
      client.connect
    
      # Construir el tópico usando el esp32_mac_address del controlador
      topic = "#{controller.esp32_mac_address}"  # Aquí usamos el MAC address como parte del tópico
    
      # Suscribirse al tópico dinámico
      client.subscribe(topic)
    
      # Usar un hilo para escuchar mensajes de forma continua
      Thread.new do
        begin
          client.get do |topic, message|
            Rails.logger.info "Mensaje recibido en el tópico #{topic}: #{message}"
    
            # Procesar el mensaje (puedes cambiar la lógica aquí según tu necesidad)
            data = JSON.parse(message)
            last_connected_at = Time.parse(data["time"])  # Almacenar el tiempo de la última conexión
            controller = Controller.find_by(esp32_mac_address: data["controller_id"])
            if controller
              controller.update(last_seen_at: last_connected_at)
            else
              Rails.logger.warn "Controlador no encontrado para ID: #{data["controller_id"]}"
            end
          end
        rescue StandardError => e
          Rails.logger.error "Error durante la suscripción: #{e.message}"
        ensure
          client.disconnect
        end
      end
    
      # render json: { message: "Escuchando los mensajes en el tópico #{topic}" }
    end
    
=======
>>>>>>> ada53881760a2ae27629f0e9906414954403b406
  end
