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

describe ZohoReports::Client do
  before :each do
    ZohoReports.configure do |config|
      config.auth_token = 'token'
      config.login_email = 'user@example.com'
      config.zoho_database_name = 'test_database'
    end

    @client = ZohoReports::Client.new
  end

  context "#new" do
    it "should initialize with options" do
      expect(@client.api_version).to eq('1.0')
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
      response = @client.add_row("widgets", new_row)
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
      response = @client.update_data("widgets", row_data, criteria)
      expect(response.success?).to be true
    end
  end

  context "#import_data" do
    it "should ADD a single row" do

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
      response = @client.import_data("widgets", 'APPEND', row_data.to_json)
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
      response = @client.import_data("widgets", 'UPDATEADD', row_data.to_json, 'ZOHO_MATCHING_COLUMNS' => 'id')
      expect(response.success?).to be true
    end

    it "should ADD multiple rows" do

      row_data = [
        { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' },
        { id: 2, name: 'Acme 2nd Widget', description: '2nd Widget from Acme for Testing', active: 't' }
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
      response = @client.import_data("widgets", 'APPEND', row_data.to_json)
      expect(response.success?).to be true
    end

    it "should UPDATE mutliple rows" do

      row_data = [
        { id: 1, name: 'Acme Widget Revision', description: 'Widget from Acme for Testing', active: 't' },
        { id: 2, name: 'Acme 2nd Widget', description: '2nd Widget from Acme for Testing', active: 't' }
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
      response = @client.import_data("widgets", 'UPDATEADD', row_data.to_json, 'ZOHO_MATCHING_COLUMNS' => 'id')
      expect(response.success?).to be true
    end
  end
end