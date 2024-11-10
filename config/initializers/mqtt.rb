require 'mqtt'

MQTT_BROKER_URL = 'mqtt://broker_address' # no lo tenemos todavia asi q esta blank!!!
MQTT_TOPIC_PASSWORDS = 'lockers/passwords/update' # estoy asumiendo un nombre nomas, da lo mismo si lo cambiamos

#MQTT_CLIENT = MQTT::Client.connect(MQTT_BROKER_URL)

# subscripcion a topic de status de controladores
#MQTT_CLIENT.subscribe("controllers/status")

#MQTT_CLIENT.subscribe("controllers/status") do |topic, message|
#  if topic == "controllers/status"
#    MqttService.process_status_message(message)
#  end
#end
