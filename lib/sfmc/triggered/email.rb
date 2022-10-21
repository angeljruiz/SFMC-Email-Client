module SFMC
  module Triggered
    class Email < SFMCBase
      def self.send_email(email:, to:, params: {})
        endpoint_url = "/messaging/v1/messageDefinitionSends/key:#{email}/send"
        email_params = {
          To: {
            Address: to,
            SubscriberKey: get_subscriber_key(to),
            ContactAttributes: {
              SubscriberAttributes: params,
            },
          },
        }

        request(:post, endpoint_url, email_params.as_json)
      end
    end
  end
end
