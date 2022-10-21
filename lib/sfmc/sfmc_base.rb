require 'httparty'

module SFMC
  class SFMCBase
    include HTTParty
    extend SFMC::Helpers
    extend SFMC::Errors

    format :json

    NAME_TO_METHOD = {
      find: :get,
      create: :post,
      update: :patch,
      destroy: :delete,
    }.freeze

    class << self
      # This protects against an invalid access token, for instance if the SFMC password was changed
      def authenticate_and_retry(method, endpoint, params, retry_count)
        SFMC::Authentication.set_bearer_token refresh: true
        request method, endpoint, params, retry_count - 1
      end

      def request(http_method, endpoint, params = {}, retry_count = 1, is_authenticating: false)
        unless is_authenticating
          set_base_uri
          SFMC::Authentication.set_bearer_token
        end

        received = method(http_method).call(endpoint, body: params, headers: SFMCBase.headers)
        payload = JSON.parse(received.to_json, object_class: OpenStruct)

        return payload if received.response.is_a? Net::HTTPSuccess

        raise error_class(received.code), error_message(received) unless received.code == 401 && retry_count > 0

        # The access token was invalidated. In this case, by default, we will retry once
        authenticate_and_retry http_method, endpoint, params, retry_count
      end

      protected

      attr_accessor :access_token,
                    :access_token_expires_at,
                    :subdomain,
                    :client_id,
                    :client_secret,
                    :default_send_classification,
                    :default_subscriber_list,
                    :default_data_extension,
                    :default_bcc

      def endpoint(path)
        return if defined? @endpoint_defined

        @endpoint_defined = true
        extend @endpoint_module = Module.new

        # Defines the CRUD methods find, create, update, and destroy
        # Each method optionally accepts an id of a resource, params, and auth
        # The auth param should never be used directly
        @endpoint_module.module_eval do
          NAME_TO_METHOD.each do |name, method|
            define_method(name) do |id = nil, params = nil, auth = false|
              path_with_id = path + "/#{id}"

              request method, path_with_id, params, is_authenticating: auth
            end
          end

          # Defines a resource query method
          # The query param is the query to be sent,
          # and the optional fields param, when set, will only return those specific fields
          define_method("query") do |query, fields = nil|
            query += "&$fields=#{URI::Parser.new.escape(fields)}" unless fields.nil?

            find("?$filter=#{query}")
          end
        end
      end
    end
  end
end
