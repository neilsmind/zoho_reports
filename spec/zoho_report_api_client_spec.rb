require 'spec_helper'

describe ZohoReportApiClient::Client do
  before :each do
    @client = ZohoReportApiClient::Client.new(login_email: 'user@example.com', auth_token: 'token')
  end

  context "#new" do
    it "should initialize with options" do
      options = { login_email: 'user@example.com', auth_token: 'token' }
      client = ZohoReportApiClient::Client.new(options)
      expect(client.login_email).to eq('user@example.com')
      expect(client.auth_token).to eq('token')
      expect(client.api_version).to eq('1.0')
    end
  end

  context "#add_row" do
    it "should add a row" do

      new_row = {
        id: 1,
        name: 'Acme Widget',
        description: 'Widget from Acme for Testing',
        active: 't',
      }
      uri = Addressable::URI.new
      uri.query_values = new_row
      stub_zoho_request :post, "test_database/widgets", "ADDROW", response_filename: "add_row.json", body: uri.query
      response = @client.add_row("test_database", "widgets", new_row)
      expect(response.success?).to be true
    end
  end

  # context "#update_data" do
  #   before do 
  #     stub_zoho_request :post, "test_database/widgets", "UPDATE", "update.json"
  #   end

  #   it "should update a row" do

  #     new_row_data = {
  #       id: 1,
  #       name: 'Acme Widget',
  #       description: 'Widget from Acme for Testing',
  #       active: 't'
  #     }
  #     response = @client.update_data("test_database", "widgets", new_row)
  #     expect(response.success?).to be true
  #   end
  # end
end