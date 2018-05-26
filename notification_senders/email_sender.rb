require "kafka"
require "logger"
require "redis"
require "json"
redis = Redis.new

logger = Logger.new("/Users/underscore/meesho/email.log")

brokers = ["localhost:9092"]

topic = "email"

kafka = Kafka.new(
  seed_brokers: brokers,
  client_id: "email_sender",
  socket_timeout: 20
)

kafka.each_message(topic: topic) do |message|
  data = JSON.parse(message.value)
  if redis.get(data["message_id"]).nil?
    redis.set(data["message_id"])
    puts "sending email receipients:#{data["receipients"]} body:#{data["body"]} attachment:#{data["attachment"]}"
    logger.warn("sending email receipients:#{data["receipients"]} body:#{data["body"]} attachment:#{data["attachment"]}")
  end
end
