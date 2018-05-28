require 'json'
require './receipients'
module Notification
  class SmsNotifier

    include Receipients

    def initialize(params={})
      @receipients = params["receipients"]
      @order = params["order"]
      @body = params["body"]
      @producer = params["producer"] || params[:producer]
    end

    def topic
      "sms"
    end

    def message_id
      "#{Time.now}:message:order:#{order}"  #TODO Make a better relevant key
    end

    def producer
      @producer
    end

    def order
      @order
    end

    def receipients
      @receipients.map do |receipient|
        public_send(receipient,order,"phone_no")
      end
    end

    def body
      @body #TODO populate string template with order related variables
    end

    def send
      puts "sending sms  body:#{body}"
      begin
        producer.produce({"receipients": receipients,"body": body,message_id: message_id}.to_json, topic: topic)
        producer.deliver_messages
      rescue => e
        puts e
      end
    end

  end
end
