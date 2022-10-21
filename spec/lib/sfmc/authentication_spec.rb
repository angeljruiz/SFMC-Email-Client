require 'spec_helper'

module SFMC
  class AuthenticationTestClass < Authentication
    endpoint '/test'

    def self.reset_auth
      SFMCBase.access_token = nil
    end

    def self.get_access_token
      SFMCBase.access_token
    end
  end
end

RSpec.describe SFMC::Authentication do
  subject { SFMC::AuthenticationTestClass }

  let(:token) { 'a30d2a4c-b699-4aef-98da-d0916bd8bc1b' }
  let(:access_token) { OpenStruct.new({ access_token: token, expires_in: 1080 }) }

  before do
    subject.reset_auth
  end

  it 'gets the access token' do
    expect(subject).to receive(:create)
                         .once
                         .and_return(access_token)
    expect(subject.get_access_token).to be_nil

    subject.set_bearer_token

    expect(subject.get_access_token).to eq(token)
  end

  it "doesn't get another token if it is valid" do
    expect(subject).to receive(:create)
                         .once
                         .and_return(access_token)
    expect(subject.get_access_token).to be_nil

    subject.set_bearer_token
    subject.set_bearer_token

    expect(subject.get_access_token).to eq(token)
  end

  it "gets an access token if current one is nil" do
    expect(subject).to receive(:create)
                         .twice
                         .and_return(access_token)
    expect(subject.get_access_token).to be_nil

    subject.set_bearer_token
    subject.reset_auth
    subject.set_bearer_token

    expect(subject.get_access_token).to eq(token)
  end

  it "gets another access token if current one is expired" do
    access_token.expires_in = -1
    expect(subject).to receive(:create)
                         .twice
                         .and_return(access_token)
    expect(subject.get_access_token).to be_nil

    subject.set_bearer_token
    subject.set_bearer_token

    expect(subject.get_access_token).to eq(token)
  end
end
