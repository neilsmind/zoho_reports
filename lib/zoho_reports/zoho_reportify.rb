require 'active_support'
require 'active_support/concern'
require 'active_record'


module ZohoReports
  module ZohoReportify
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def zoho_reportify(options = {})
        after_save :save_zoho_record

        def self.zoho_table_name
          self.name.pluralize.underscore
        end

        def self.initialize_zoho_table
          client = ZohoReports::Client.new

          ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

          # Notice the ZOHO_DATE_FORMAT here
          client.import_data(
            zoho_table_name, 
            'UPDATEADD', 
            all.to_json, 
            'ZOHO_CREATE_TABLE' => 'true', 
          )

          # Turn standard json back on
          ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
        end

        include ZohoReports::ZohoReportify::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def save_zoho_record
        client = ZohoReports::Client.new

        ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

        # Notice the ZOHO_DATE_FORMAT here
        client.import_data(
          self.class.zoho_table_name, 
          'UPDATEADD', 
          self.class.where(id: id).to_json, 
        )

        # Turn standard json back on
        ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
      end

      def to_zoho_json
        # store the current json setting so we can set it back to its original format
        current_json_setting = ActiveSupport::JSON::Encoding.use_standard_json_time_format

        # temporarily turn off standard json format for Zoho Reports
        ActiveSupport::JSON::Encoding.use_standard_json_time_format = false
        
        # export to json in the format required by Zoho
        json = [self].to_json

        # set json formatting back to original value
        ActiveSupport::JSON::Encoding.use_standard_json_time_format = current_json_setting

        return json
      end
    end

    # def zoho_reportify(options = nil)
    #   after_save do |record|
    #     ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

    #     client = ZohoReports::Client.new
    #     client.import_data(
    #       self.class.name.pluralize.underscore, 
    #       'UPDATEADD', 
    #       [self.to_json], 
    #       'ZOHO_MATCHING_COLUMNS' => 'id', 
    #       'ZOHO_CREATE_TABLE' => 'true', 
    #       'ZOHO_DATE_FORMAT' => 'yyyy/MM/dd HH:mm:ss Z'
    #     )

    #     ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
    #   end
    # end
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :include, ZohoReports::ZohoReportify

# ActiveRecord::Base.send :extend, ZohoReportify