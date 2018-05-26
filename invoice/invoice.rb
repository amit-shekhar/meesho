fork do
  require "kafka"
  require "logger"
  require "redis"
  require 'json'
  redis = Redis.new

  logger = Logger.new("/Users/underscore/meesho/invoice.log")

  brokers = ["localhost:9092"]

  topic = "order"

  kafka = Kafka.new(
    seed_brokers: brokers,
    client_id: "invoice",
    socket_timeout: 20
  )

  kafka.each_message(topic: topic) do |message|

    #TODO check for valid order_ids

    begin
      data = JSON.parse(JSON.parse(message.value))
      order_id = data["order_id"]
      puts order_id
      if !order_id.nil?
        logger.warn("order_id:#{message.value} request")
        sleep 20 #TODO create invoice 
        redis.set("order:invoice:#{message.value}",1)
        logger.warn("order_id:#{message.value} processed")
      end
    rescue => e
      puts "Error parsing message"
    end

  end

end
#
fork do
  require 'sinatra'
  require "redis"
  require "json"
  redis = Redis.new

  get '/invoice/:id' do
    puts "order:invoice:#{params[:id]}"
    invoice = redis.get("order:invoice:#{params[:id]}")
    if invoice.nil?
     return {attachment: ""}.to_json
    else
      return  {attachment: invoice}.to_json
    end
  end

end
