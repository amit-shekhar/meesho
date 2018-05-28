require 'net/http'
module Notification
  module Receipients

    #TODO use different classes for email and sms

    def customer(order)
      #TODO Find order customer and return order.customer.email or order.customer.phone_no
      "1234567890"
    end

    def default(order)
      "0000000000"
    end

    #TODO add other receipients
  end
end
