module SFMC
  module Contacts
    class ContactKey < SFMCBase
      endpoint "/contacts/v1/addresses/email/search"

      def self.find(emails, max = 1)
        emails = [emails] unless emails.is_a? Array

        params = {
          channelAddressList: emails,
          maximumCount: max,
        }
        response = create(nil, params)

        response.channelAddressResponseEntities.map do |channel|
          key = channel[:contactKeyDetails].first[:contactKey]
          raise SFMC::Errors::NotFoundError if key.nil?

          key
        end
      end
    end
  end
end
