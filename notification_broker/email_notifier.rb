require "./attachments"

module Notification
  class EmailNotifier

    include Attachments

    def initialize(params={})
      @receipients = params["receipients"]
      @order = params["order_id"] || params["order"] || params[:order_id] || params[order]
      @body = params["body"] || params[:body]
      @producer = params["producer"] || params[:producer]
      @attachments = params["attachments"]
      @type = params["type"] || params[:type]
    end

    def topic
      "email"
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
      @receipients
    end

    def body
      @body
    end

    def attachments
      @attachments
    end

    def attachment_details
      @attachment_details ||= ""
    end

    def add_attachments
      error = false
      attachments.each do |attachment|
        url = public_send(attachment["name"],order)
        if url.empty?
          error = true
          @body = @body + attachment["missing_text"].to_s
        else
          @attachment_details += url #TODO attaching a file
        end
      end
      error
    end

    def send
      if !add_attachments
        add_to_attachment_queue
      end
      puts "sending email body:#{body}"
      begin
        producer.produce({"receipients": receipients,"body": body,"attachment": attachment_details,message_id: message_id}.to_json, topic: topic)
        producer.deliver_messages
      rescue => e
        puts e
      end
    end

    def add_to_attachment_queue
      begin
        producer.produce({"type": @type,"order_id": order,"retry_count": 0}.to_json, topic: "attachement_missing")
        producer.deliver_messages
      rescue => e
        puts e
      end
    end
  end
end
