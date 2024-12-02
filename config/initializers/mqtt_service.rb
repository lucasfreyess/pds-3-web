Rails.application.config.after_initialize do
    MqttService.start
    #MqttSubscriptionJob.perform_later
end
