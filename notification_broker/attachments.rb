require 'net/http'
module Notification
  module Attachments
    def invoice(order_id)
      url = URI.parse("http://localhost/invoice/#{order_id}")
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host,4567) {|http|
        http.request(req)
      }
      return JSON.parse(res.body)["attachment"]
    end

    #TODO Add other attachment types
    
  end
end

#
# puts Notification::Attachments.invoice("123")
