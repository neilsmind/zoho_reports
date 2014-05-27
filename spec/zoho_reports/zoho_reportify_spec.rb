require "spec_helper"

module ZohoReports
  describe ZohoReportify do
    before do 
      ZohoReports.configure do |config|
        config.auth_token = 'token'
        config.login_email = 'user@example.com'
        config.zoho_database_name = 'test_database'
      end

      @stub = stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json"
    end
    describe ".initialize_zoho_table" do

      it "sends a proper request to import records into Zoho Reports" do
        Widget.create(name: 'Baby-inator', description: 'Turns people into babies')
        Widget.create(name: 'Deflate-inator Ray', description: 'Deflate every inflatable in the Tri-State Area')
        
        response = Widget.initialize_zoho_table
        
        zoho_all = []
        
        Widget.all.each do |widget|
          zoho_all << ZohoReports::Client.zoho_attributes(widget.attributes)
        end
        
        expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
          .with(:query => {
                  'ZOHO_ACTION' => 'IMPORT', 
                  'authtoken' => ZohoReports.configuration.auth_token,
                  'ZOHO_OUTPUT_FORMAT' => 'JSON',
                  'ZOHO_ERROR_FORMAT' => 'JSON',
                  'ZOHO_API_VERSION' => '1.0',
                },
                :body => query_string({
                  'ZOHO_AUTO_IDENTIFY' => 'true',
                  'ZOHO_ON_IMPORT_ERROR' => 'SETCOLUMNEMPTY',
                  'ZOHO_CREATE_TABLE' => 'true',
                  'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
                  'ZOHO_IMPORT_DATA' => zoho_all.to_json,
                  'ZOHO_IMPORT_FILETYPE' => 'JSON',
                  'ZOHO_MATCHING_COLUMNS' => 'id', 
                  'ZOHO_DATE_FORMAT' => "yyyy/MM/dd HH:mm:ss Z"
                }))
      end
    end

    context "when object created" do
      it "should send an update to Zoho Reports" do
        # Create an initial widget
        @widget = Widget.create(name: 'Baby-inator', description: 'Turns people into babies')

        # Update an attribute
        @widget.description = 'Turns people into whiny babies'

        # Save the update
        @widget.save

        expect(WebMock).to have_requested(:post, "https://reportsapi.zoho.com/api/user@example.com/test_database/widgets")
          .with(:query => {
                  'ZOHO_ACTION' => 'IMPORT', 
                  'authtoken' => ZohoReports.configuration.auth_token,
                  'ZOHO_OUTPUT_FORMAT' => 'JSON',
                  'ZOHO_ERROR_FORMAT' => 'JSON',
                  'ZOHO_API_VERSION' => '1.0',
                },
                :body => query_string({
                  'ZOHO_AUTO_IDENTIFY' => 'true',
                  'ZOHO_ON_IMPORT_ERROR' => 'SETCOLUMNEMPTY',
                  'ZOHO_CREATE_TABLE' => 'false',
                  'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
                  'ZOHO_IMPORT_DATA' => [ZohoReports::Client.zoho_attributes(@widget.attributes)].to_json,
                  'ZOHO_IMPORT_FILETYPE' => 'JSON',
                  'ZOHO_MATCHING_COLUMNS' => 'id',
                  'ZOHO_DATE_FORMAT' => "yyyy/MM/dd HH:mm:ss Z",
                }))
      end
    end
  end
end