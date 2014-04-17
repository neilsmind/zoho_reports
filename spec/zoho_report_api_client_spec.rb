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
      stub_zoho_request :post, "test_database/widgets", "ADDROW", response_filename: "add_row.json", body: query_string(new_row)
      response = @client.add_row("test_database", "widgets", new_row)
      expect(response.success?).to be true
    end
  end

  context "#update_data" do
    it "should update a row" do

      row_data = {
        id: 1,
        name: 'Acme Widget',
        description: 'Widget from Acme for Testing',
        active: 't'
      }
      criteria = '(id: 1)'
      body = row_data.merge({:ZOHO_CRITERIA => criteria})
      
      stub_zoho_request :post, "test_database/widgets", "UPDATE", response_filename: "update.json", body: query_string(body)
      response = @client.update_data("test_database", "widgets", row_data, criteria)
      expect(response.success?).to be true
    end
  end

  context "#import_data" do
    it "should import a single row" do

      row_data = [
        { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' }
      ]
      
      body = {
        'ZOHO_AUTO_IDENTIFY' => 'true',
        'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
        'ZOHO_CREATE_TABLE' => 'false',
        'ZOHO_IMPORT_TYPE' => 'APPEND',
        'ZOHO_IMPORT_DATA' => row_data.to_json,
        'ZOHO_IMPORT_FILETYPE' => 'JSON',
      }
      stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json", body: query_string(body)
      response = @client.import_data("test_database", "widgets", 'APPEND', row_data.to_json)
      expect(response.success?).to be true
    end

    it "should UPDATE a single row" do

      row_data = [
        { id: 1, name: 'Acme Widget Revision', description: 'Widget from Acme for Testing', active: 't' }
      ]
      
      body = {
        'ZOHO_AUTO_IDENTIFY' => 'true',
        'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
        'ZOHO_CREATE_TABLE' => 'false',
        'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
        'ZOHO_IMPORT_DATA' => row_data.to_json,
        'ZOHO_IMPORT_FILETYPE' => 'JSON',
        'ZOHO_MATCHING_COLUMNS' => 'id',
      }

      stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json", body: query_string(body)
      response = @client.import_data("test_database", "widgets", 'UPDATEADD', row_data.to_json, 'ZOHO_MATCHING_COLUMNS' => 'id')
      expect(response.success?).to be true
    end
  end
end