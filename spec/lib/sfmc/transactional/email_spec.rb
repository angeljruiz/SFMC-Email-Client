require 'spec_helper'

module SFMC
  module Transactional
    class TestClass < Email
      endpoint '/test'

      def self.reset_auth
        SFMCBase.access_token = nil
      end
    end
  end
end

RSpec.describe SFMC::Transactional::Email do
  subject { SFMC::Transactional::TestClass }

  let(:access_token) { OpenStruct.new({ access_token: 'a30d2a4c-b699-4aef-98da-d0916bd8bc1b', expires_in: 1080 }) }
  let(:email_address) { 'find-me@angelruizbates.com' }
  let(:email_name) { 'test_email' }

  before do
    subject.reset_auth
  end

  it "generates a new subscriber key if one isn't found" do
    allow(SFMC::Contacts::ContactKey).to receive(:find).and_raise(SFMC::Errors::NotFoundError)

    expect(subject.get_subscriber_key(email_address)).to be_a(String)
  end

  it "creates an email send definition if #send_email raises a not found error" do
    allow(SFMC::Contacts::ContactKey).to receive(:find).and_raise(SFMC::Errors::NotFoundError)
    allow(SFMC::Transactional::SendDefinition).to receive(:refresh)
    allow(subject).to receive(:create)
                       .twice
                       .and_raise SFMC::Errors::NotFoundError
    expect(subject).to receive(:create_email_send_definition)

    subject.send_email(email: email_name, to: email_address)
  end
end
