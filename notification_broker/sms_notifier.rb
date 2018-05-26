require 'json'
module Notification
  class SmsNotifier

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
      # receipients_list = []
      # @receipients.each do ||

      # end
      @receipients
    end

    # def receipients_list
    #
    # end

    def body
      @body
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
