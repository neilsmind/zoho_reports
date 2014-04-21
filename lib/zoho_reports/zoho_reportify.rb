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

          client.import_data(
            self.table_name, 
            'UPDATEADD', 
            all.to_json, 
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
          self.class.where(id: id).to_json, 
        )

        # Turn standard json back on
        
      end
    end
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :include, ZohoReports::ZohoReportify

# ActiveRecord::Base.send :extend, ZohoReportify