module SFMC::Helpers
  def init(config)
    @subdomain = config[:subdomain]
    @client_id = config[:client_id]
    @client_secret = config[:client_secret]
    @default_send_classification = config[:default_send_classification]
    @default_subscriber_list = config[:default_subscriber_list]
    @default_data_extension = config[:default_data_extension]
    @default_bcc = config[:default_bcc]
  end

  def set_base_uri(protocol = 'rest')
    base_uri "https://#{SFMC::SFMCBase.subdomain}.#{protocol}.marketingcloudapis.com"
  end

  def get_subscriber_key(email_address)
    begin
      SFMC::Contacts::ContactKey.find(email_address).first
    rescue SFMC::Errors::NotFoundError
      SecureRandom.uuid
    end
  end
end
