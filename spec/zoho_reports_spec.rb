require 'spec_helper'

describe ZohoReports do
  describe "#configure" do
    before do
      ZohoReports.configure do |config|
        config.auth_token = 'token'
        config.login_email = 'user@example.com'
        config.zoho_database_name = 'test_database'
      end
    end

    it "returns a user_uri with the configuratoin login_email embedded" do
      user_uri = ZohoReports::Client.new.get_user_uri

      expect(user_uri).to eq('/user@example.com')

    end
  end
end