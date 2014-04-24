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

        def self.initialize_zoho_table
          client = ZohoReports::Client.new

          # Pre-process attributes to be better with Zoho
          zoho_all = []
          all.each do |model|
            zoho_all << ZohoReports::Client.zoho_attributes(model.attributes)
          end

          client.import_data(
            self.table_name, 
            'UPDATEADD', 
            zoho_all.to_json, 
            'ZOHO_CREATE_TABLE' => 'true', 
          )

        end

        include ZohoReports::ZohoReportify::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def save_zoho_record
        client = ZohoReports::Client.new

        # Notice the ZOHO_DATE_FORMAT here
        client.import_data(
          self.class.table_name, 
          'UPDATEADD', 
          [ZohoReports::Client.zoho_attributes(self.attributes)].to_json, 
        )

        # Turn standard json back on
        
      end
    end
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :include, ZohoReports::ZohoReportify

# ActiveRecord::Base.send :extend, ZohoReportify