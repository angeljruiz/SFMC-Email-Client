require 'spec_helper'

module SFMC
  class BaseTestClass < SFMCBase
    endpoint '/test'

    def self.reset_auth
      SFMCBase.access_token = nil
    end
  end
end

def stub_endpoint_request(method, status = 200, body = "{}")
  stub_request(method, subject.set_base_uri + endpoint_with_id).to_return(status: status, body: body)
end

RSpec.describe SFMC::SFMCBase do
  subject { SFMC::BaseTestClass }

  let(:id) { "test_id" }
  let(:test_params) { { test: "params" } }
  let(:auth) { false }
  let(:endpoint_with_id) { "/test/#{id}" }
  let(:access_token) { OpenStruct.new({ access_token: 'a30d2a4c-b699-4aef-98da-d0916bd8bc1b', expires_in: 1080 }) }

  before do
    subject.reset_auth
  end

  it 'defines the CRUD methods' do
    SFMC::SFMCBase::NAME_TO_METHOD.each do |name, method|
      expect(subject).to receive(:request) do |http_method, endpoint, params, is_authenticating|
        expect(http_method).to eq method
        expect(endpoint).to eq endpoint_with_id
        expect(params).to eq test_params
        expect(is_authenticating).to eq is_authenticating: auth
      end

      subject.method(name).call id, test_params, auth
    end
  end

  it 'defines the query class method' do
    expect(subject).to receive(:request).with(:get, any_args)

    subject.query test_params
  end

  it 'authenticates only on the first request' do
    expect(SFMC::Authentication).to receive(:create)
                                        .once
                                        .and_return(access_token)
    stub_endpoint_request(:get, 200)

    subject.find(id)
    subject.find(id)
  end

  it 're-authenticates when the access token is invalidated' do
    expect(SFMC::Authentication).to receive(:create)
                                        .twice
                                        .and_return(access_token)
    stub_endpoint_request(:get, 200)

    subject.find(id)
    stub_endpoint_request(:get, 401)

    expect do
      subject.find(id)
    end.to raise_exception SFMC::Errors::UnauthorizedError
  end
end
