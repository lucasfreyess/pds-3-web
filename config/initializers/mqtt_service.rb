Rails.application.config.after_initialize do
    MqttService.start
end
  