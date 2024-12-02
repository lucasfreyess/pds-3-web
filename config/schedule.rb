# config/schedule.rb

every 1.minute do
  runner "MqttSubscriptionJob.perform_later"
end
