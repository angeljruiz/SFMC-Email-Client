module SFMC
  module Transactional
    class Email < SFMCBase
      endpoint "/messaging/v1/email/messages"

      # If an email hasn't ever been sent then we will not have an email send definition
      # We're waiting a minute for the send definition to fully be initialized
      # Thankfully this is a rare edge case
      def self.create_email_send_definition(name)
        asset = SFMC::Assets::Asset.query("name eq '#{name}'", 'customerKey')
        raise SFMC::Errors::BadRequestError, "No emails found with name #{name}" if asset.count == 0

        consumer_key = asset.items.first["customerKey"]

        SFMC::Transactional::SendDefinition.create(definition_key: name, customer_key: consumer_key)

        # Even though the send def is "Active" it won't function for another minute
        pp "Email send definition inactive. Try again in a minute"
      end

      # Will attempt once to create a new email send definition if one isn't found
      def self.send_email(email:, to:, params: {}, create_email_if_needed: true)
        subscriber_key = get_subscriber_key(to)
        message_key = SecureRandom.uuid
        data_extension_params = {
          SubscriberKey: subscriber_key,
          EmailAddress: to,
          **params,
        }

        email_params = {
          definitionKey: email,
          recipient: {
            contactKey: subscriber_key,
            to: to,
            attributes: data_extension_params,
          },
        }

        # If SFMC::Errors::NotFoundError is raised then we need to create an email send definition
        begin
          create(message_key, email_params)
        rescue SFMC::Errors::NotFoundError
          raise unless create_email_if_needed

          create_email_send_definition(email)
        end
      end
    end
  end
end
