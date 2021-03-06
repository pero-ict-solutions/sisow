module Sisow
  module Api
    class TransactionRequest < Request

      attr_accessor :purchase_id,
                    :issuer_id,
                    :description,
                    :amount,
                    :payment

      def initialize(payment)
        @payment = payment
      end

      def method
        'TransactionRequest'
      end

      def params
        default_params.merge!(transaction_params)
      end

      def clean(response)
        check_validity!(response)

        if response.transactionrequest? && response.transactionrequest.transaction?
          response.transactionrequest.transaction
        end
      end

      def validate!
        raise Sisow::Exception, 'One of your payment parameters is missing or invalid' unless @payment.valid?
      end

      def sha1
        string = [
          payment.purchase_id,
          payment.entrance_code,
          payment.amount,
          Sisow.configuration.merchant_id,
          Sisow.configuration.merchant_key
        ].join

        Digest::SHA1.hexdigest(string)
      end

      private

        def transaction_params
          {
            :payment      => payment.payment_method,
            :purchaseid   => payment.purchase_id,
            :amount       => payment.amount,
            :issuerid     => payment.issuer_id,
            :description  => payment.description,
            :entrancecode => payment.entrance_code,
            :returnurl    => payment.return_url,
            :cancelurl    => payment.cancel_url,
            :callbackurl  => payment.callback_url,
            :notifyurl    => payment.notify_url,
            :shop_id      => payment.shop_id,
            :sha1         => sha1
          }
        end

        def payment
          @payment
        end

        def check_validity!(response)
          string = [
            response.transactionrequest.transaction.trxid,
            response.transactionrequest.transaction.issuerurl,
            Sisow.configuration.merchant_id,
            Sisow.configuration.merchant_key
          ].join
          calculated_sha1 = Digest::SHA1.hexdigest(string)

          if calculated_sha1 != response.transactionrequest.signature.sha1
            raise Sisow::Exception, "This response has been forged" and return
          end
        end

    end
  end
end
