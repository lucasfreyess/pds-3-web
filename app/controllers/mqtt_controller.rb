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
  end
  