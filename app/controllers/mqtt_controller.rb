# app/controllers/mqtt_controller.rb
class MqttController < ApplicationController
    def send_message
      # Dirección IP del broker remoto o dominio
      broker_ip = "localhost"
  
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
  
    def subscribe_to_topic

      # Dirección IP del broker remoto o dominio
      broker_ip = "172.28.143.35" 
  
      # Conéctate al broker
      client = MQTT::Client.new("mqtt://#{broker_ip}")
      client.connect
  
      # Suscríbete al tópico y define el comportamiento cuando se reciba un mensaje
      client.get('esp32/topic') do |topic, message|
        Rails.logger.info "Mensaje recibido en el tópico #{topic}: #{message}"
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
      broker_ip = "localhost"
    
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
      topic = params[:topic] || "controlador/#{@controller.id}"  # Usar el ID del controlador en el topic si no se pasa uno
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
    
  end
  