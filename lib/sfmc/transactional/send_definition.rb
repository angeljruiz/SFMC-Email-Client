module SFMC
  module Transactional
    class SendDefinition < SFMCBase
      endpoint "/messaging/v1/email/definitions"

      def self.refresh(definition_key)
        update definition_key, status: 'Inactive'
        update definition_key, status: 'Active'
      end

      def self.create(
        definition_key:,
        customer_key:,
        send_classification: nil,
        subscriber_list: nil,
        data_extension: nil,
        bcc: []
      )
        params = {
          classification: SFMCBase.default_send_classification || send_classification,
          definitionKey: definition_key,
          name: definition_key,
          status: 'Active',
          subscriptions: {
            list: SFMCBase.default_subscriber_list || subscriber_list,
            dataExtension: SFMCBase.default_data_extension || data_extension,
          },
          content: {
            customerKey: customer_key,
          },
          options: {
            bcc: SFMCBase.default_bcc || bcc,
          },
        }

        super(nil, params)
      end
    end
  end
end
