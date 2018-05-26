require "kafka"
require "logger"
require "redis"
require "json"
redis = Redis.new

logger = Logger.new("/Users/underscore/meesho/sms.log")

brokers = ["localhost:9092"]

topic = "sms"

kafka = Kafka.new(
  seed_brokers: brokers,
  client_id: "sms_sender",
  socket_timeout: 20
)

kafka.each_message(topic: topic) do |message|
  data = JSON.parse(message.value)
  if redis.get(data["message_id"]).nil?
    redis.set(data["message_id"])
    puts "sending sms receipients:#{data["receipients"]} body:#{data["body"]}"
    logger.warn("sending sms receipients:#{data["receipients"]} body:#{data["body"]}")
  end
end
