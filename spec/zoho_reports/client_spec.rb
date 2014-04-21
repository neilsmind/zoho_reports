require 'spec_helper'

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
    before do
      @stub = stub_zoho_request :post, "test_database/widgets", "ADDROW", response_filename: "add_row.json"
    end

    it "should add a row" do
      widget = { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' }
      response = @client.add_row("widgets", widget)

      expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
        .with(:query => {
                'ZOHO_ACTION' => 'ADDROW', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0'
              },
              :body => query_string({ id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' }))
    end
  end

  context "#update_data" do
    before do
      @stub = stub_zoho_request :post, "test_database/widgets", "UPDATE", response_filename: "update.json"
    end

    it "should update a row" do
      widget = { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' }
      criteria = "(id: 1)"
      response = @client.update_data("widgets", widget, criteria)
      
      expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
        .with(:query => {
                'ZOHO_ACTION' => 'UPDATE', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0'
              },
              :body => query_string({ id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't', :ZOHO_CRITERIA => criteria }))
      end
    end

  context "#import_data" do
    before do
      @stub = stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json"
    end

    it "should ADD a single row" do

      widget = [ { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' } ]
      
      response = @client.import_data("widgets", 'APPEND', widget.to_json)
       expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
        .with(:query => {
                'ZOHO_ACTION' => 'IMPORT', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0',
              },
              :body => {
                'ZOHO_AUTO_IDENTIFY' => 'true',
                'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
                'ZOHO_CREATE_TABLE' => 'false',
                'ZOHO_IMPORT_TYPE' => 'APPEND',
                'ZOHO_IMPORT_DATA' => widget.to_json,
                'ZOHO_IMPORT_FILETYPE' => 'JSON',
                'ZOHO_MATCHING_COLUMNS' => 'id', 
                'ZOHO_MATCHING_COLUMNS' => 'id',
                'ZOHO_DATE_FORMAT' => "yyyy-MM-dd'T'HH:mm:ssZ"
              })
    end

    it "should UPDATE a single row" do

      widget = [ { id: 1, name: 'Acme Widget Revision', description: 'Widget from Acme for Testing', active: 't' } ]
      
      response = @client.import_data("widgets", 'UPDATEADD', widget.to_json)
      expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
        .with(:query => {
                'ZOHO_ACTION' => 'IMPORT', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0',
              },
              :body => {
                'ZOHO_AUTO_IDENTIFY' => 'true',
                'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
                'ZOHO_CREATE_TABLE' => 'false',
                'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
                'ZOHO_IMPORT_DATA' => widget.to_json,
                'ZOHO_IMPORT_FILETYPE' => 'JSON',
                'ZOHO_MATCHING_COLUMNS' => 'id', 
                'ZOHO_MATCHING_COLUMNS' => 'id',
                'ZOHO_DATE_FORMAT' => "yyyy-MM-dd'T'HH:mm:ssZ"
              })
    end

    it "should ADD multiple rows" do

      widgets =[
        { id: 1, name: 'Acme Widget', description: 'Widget from Acme for Testing', active: 't' },
        { id: 2, name: 'Acme 2nd Widget', description: '2nd Widget from Acme for Testing', active: 't' }
      ]
      
      response = @client.import_data("widgets", 'UPDATEADD', widgets.to_json)
      expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
        .with(:query => {
                'ZOHO_ACTION' => 'IMPORT', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0',
              },
              :body => {
                'ZOHO_AUTO_IDENTIFY' => 'true',
                'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
                'ZOHO_CREATE_TABLE' => 'false',
                'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
                'ZOHO_IMPORT_DATA' => widgets.to_json,
                'ZOHO_IMPORT_FILETYPE' => 'JSON',
                'ZOHO_MATCHING_COLUMNS' => 'id', 
                'ZOHO_MATCHING_COLUMNS' => 'id',
                'ZOHO_DATE_FORMAT' => "yyyy-MM-dd'T'HH:mm:ssZ"
              })
    end

  it "should UPDATE multiple rows" do

      widgets =[
        { id: 1, name: 'Acme Widget Revision', description: 'Widget from Acme for Testing', active: 't' },
        { id: 2, name: 'Acme 2nd Widget', description: '2nd Widget from Acme for Testing', active: 't' }
      ]
      
      response = @client.import_data("widgets", 'UPDATEADD', widgets.to_json, 'ZOHO_MATCHING_COLUMNS' => 'id')
      expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api#{@client.get_uri("widgets")}")
        .with(:query => {
                'ZOHO_ACTION' => 'IMPORT', 
                'authtoken' => ZohoReports.configuration.auth_token,
                'ZOHO_OUTPUT_FORMAT' => 'JSON',
                'ZOHO_ERROR_FORMAT' => 'JSON',
                'ZOHO_API_VERSION' => '1.0',
              },
              :body => {
                'ZOHO_AUTO_IDENTIFY' => 'true',
                'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
                'ZOHO_CREATE_TABLE' => 'false',
                'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
                'ZOHO_IMPORT_DATA' => widgets.to_json,
                'ZOHO_IMPORT_FILETYPE' => 'JSON',
                'ZOHO_MATCHING_COLUMNS' => 'id', 
                'ZOHO_MATCHING_COLUMNS' => 'id',
                'ZOHO_DATE_FORMAT' => "yyyy-MM-dd'T'HH:mm:ssZ",
                'ZOHO_MATCHING_COLUMNS' => 'id',
              })
    end
  end
end