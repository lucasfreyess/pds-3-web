require 'mqtt'

MQTT_BROKER_URL = 'mqtt://broker_address' # no lo tenemos todavia asi q esta blank!!!
MQTT_TOPIC_PASSWORDS = 'lockers/passwords/update' # estoy asumiendo un nombre nomas, da lo mismo si lo cambiamos
MQTT_TOPIC_STATUS = 'controllers/status' # lo mismo que arriba

#MQTT_CLIENT = MQTT::Client.connect(MQTT_BROKER_URL)

# subscripcion a topic de status de controladores
#MQTT_CLIENT.subscribe(MQTT_TOPIC_STATUS)

#MQTT_CLIENT.subscribe(MQTT_TOPIC_STATUS) do |topic, message|
#  if topic == "controllers/status"
#    MqttService.process_status_message(message)
#  end
#end

# ejemplo de conexion con ssl
#client = MQTT::Client.connect(
#:host => 'localhost',
#:port => 1883,
#)