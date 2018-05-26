require "kafka"
require "logger"
require "redis"
require "json"
require "./email_notifier"
require "./sms_notifier"

redis = Redis.new
logger = Logger.new("/Users/underscore/meesho/notfication.log")
brokers = ["localhost:9092"]
topic = "order"

notification_database = JSON.parse(File.read('./database.json'))
puts notification_database
kafka = Kafka.new(
  seed_brokers: brokers,
  client_id: "notification_broker",
  socket_timeout: 20
)
producer = kafka.producer
#
#
kafka.each_message(topic: topic) do |message|
  begin
    data = JSON.parse(JSON.parse(message.value))
    notification_database["#{topic}_#{data["type"]}"].each do |notification|
      case notification["type"]
      when "sms"
        Notification::SmsNotifier.new(notification.merge({producer: producer,"order_id": data["order_id"]})).send
      when "email"
        Notification::EmailNotifier.new(notification.merge({producer: producer,order_id: data["order_id"]})).send
      end
      # puts "Notification::#{notification["type"].capitalize}Notifier".constantize.new() # #TODO Figure out why not working
    end
  rescue => e
    puts "Error parsing message"
  end
end


MAX_RETRY_COUNT = 3
kafka.each_message(topic: "attachement_missing") do |message|
  begin
    data = JSON.parse(JSON.parse(message.value))
    if invoice_get
      notifiy
    else
      if data["retry_count"] + 1 < MAX_RETRY_COUNT
        data["retry_count"]  = data["retry_count"] + 1
        begin
          producer.produce(data.to_json, topic: "attachement_missing")
          producer.deliver_messages
        rescue => e
          puts e
        end
      end
    end

  rescue => e
    puts "Error parsing message"
  end
end
