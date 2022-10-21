module SFMC
  class Authentication < SFMCBase
    endpoint "/v2/token"

    def self.set_bearer_token(refresh: false)
      params = {
        client_id: SFMCBase.client_id,
        client_secret: SFMCBase.client_secret,
        grant_type: 'client_credentials',
      }

      # Ensures the token is present & not expired
      token_invalid = SFMCBase.access_token.nil? || SFMCBase.access_token_expires_at < Time.now
      return unless refresh || token_invalid

      set_base_uri 'auth'
      response = create(nil, params, true)

      SFMCBase.access_token = response.access_token
      SFMCBase.access_token_expires_at = Time.now + response.expires_in
      SFMCBase.headers Authorization: "Bearer #{SFMCBase.access_token}"
    end
  end
end
