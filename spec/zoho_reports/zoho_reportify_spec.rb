require "spec_helper"

module ZohoReports
  describe ZohoReportify do
    describe ".zoho_table_name" do
      it "returns lowercased, underscored, pluralized class name" do
        expect(Widget.zoho_table_name).to eq('widgets')
      end
    end

    describe ".initialize_zoho_table" do
      before do 
        ZohoReports.configure do |config|
          config.auth_token = 'token'
          config.login_email = 'user@example.com'
          config.zoho_database_name = 'test_database'
        end
      end

      it "sends a proper request to import records into Zoho Reports" do
        Widget.create(name: 'Baby-inator', description: 'Turns people into babies')
        Widget.create(name: 'Deflate-inator Ray', description: 'Deflate every inflatable in the Tri-State Area')
        
        # we have to disable ActiveSupport standard json time format temporarily
        ActiveSupport::JSON::Encoding.use_standard_json_time_format = false 
        
        body = {
          'ZOHO_AUTO_IDENTIFY' => 'true',
          'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
          'ZOHO_CREATE_TABLE' => 'true',
          'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
          'ZOHO_IMPORT_DATA' => Widget.all.to_json,
          'ZOHO_IMPORT_FILETYPE' => 'JSON',
          'ZOHO_MATCHING_COLUMNS' => 'id',
          'ZOHO_DATE_FORMAT' => 'yyyy/MM/dd HH:mm:ss Z',
        }
        ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
        stub = stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json", body: query_string(body)
        
        response = Widget.initialize_zoho_table
        stub.should have_been_requested

      end
    end

    context "when object created" do
      before do 
        ZohoReports.configure do |config|
          config.auth_token = 'token'
          config.login_email = 'user@example.com'
          config.zoho_database_name = 'test_database'
        end
      end

      it "should send an update to Zoho Reports" do
        stub = stub_zoho_request :post, "test_database/widgets", "IMPORT", response_filename: "import.json"

        @widget = Widget.create(name: 'Baby-inator', description: 'Turns people into babies')
        
        body = {
          'ZOHO_AUTO_IDENTIFY' => 'true',
          'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
          'ZOHO_CREATE_TABLE' => 'false',
          'ZOHO_IMPORT_TYPE' => 'UPDATEADD',
          'ZOHO_IMPORT_DATA' => @widget.to_zoho_json,
          'ZOHO_IMPORT_FILETYPE' => 'JSON',
          'ZOHO_MATCHING_COLUMNS' => 'id',
          'ZOHO_DATE_FORMAT' => 'yyyy/MM/dd HH:mm:ss Z',
        }
        
        @widget.save
        stub.should have_been_requested.with({body: body})
      end
    end
  end
end