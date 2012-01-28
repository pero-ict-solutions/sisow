module Sisow
  class Payment

    attr_accessor :purchase_id,
                  :issuer_id,
                  :description,
                  :payment_method,
                  :amount,
                  :entrance_code,
                  :return_url,
                  :cancel_url,
                  :callback_url,
                  :notify_url

    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end

    def payment_url
      request = Sisow::Api::TransactionRequest.new(self)
      response = request.perform

      CGI::unescape(response.issuerurl) if response.issuerurl?
    end

    def shop_id
      Sisow.shop_id
    end

  end
end
