require "addressable/uri"
require "httmultiparty"

module ZohoReports
  class Client
    include HTTMultiParty

    # ZohoReports provides the ruby based language binding to the http based api of ZohoReports.

    attr_accessor :auth_token, :login_email, :api_version

    base_uri "reportsapi.zoho.com:443/api"

    def initialize
      self.api_version = '1.0'
    end

    # Returns default settings for url query string on requests
    def default_query
      {
        'authtoken' => ZohoReports.configuration.auth_token,
        'ZOHO_OUTPUT_FORMAT' => 'JSON',
        'ZOHO_ERROR_FORMAT' => 'JSON',
        'ZOHO_API_VERSION' => self.api_version,
      }
    end

    def send_request(url, http_method, options = {})
      if ZohoReports.configuration.login_email.present? && ZohoReports.configuration.auth_token.present?
        # Merge our default query string values with the specificed query values
        options[:query] = default_query.merge!(options[:query])
        
        #Convert form variables to encoded string if exists
        if options.has_key?(:body)
          uri = Addressable::URI.new
          uri.query_values = options[:body]
          options[:body] = uri.query
        end

        response = self.class.send(http_method,url, options)

        if response.success?
          response
        else
          raise response.parsed_response
        end
      end
    end

    # Gets copy database key for specified database identified by the URI    
    def get_copy_db_key
      # payLoad = ReportClientHelper.getAsPayLoad([config],None,None)
      options = {
        :query => { 'ZOHO_ACTION' => 'GETCOPYDBKEY' }
      } 

      send_request get_db_uri, 'post', options
    end

    # Copy the specified database identified by the URI
    def copy_database
      options = {
        :query => { 'ZOHO_ACTION' => 'COPYDATABASE' }
      }

      send_request get_db_uri, 'post', options
    end

    # Delete the specified database
    def delete_database
      options = {
        :query => {
          'ZOHO_ACTION' => 'DELETEDATABASE',
          'ZOHO_DATABASE_NAME' => database_name,
        }
      }
      send_request get_user_uri, 'post', options
    end
 
    # Add the users to the Zoho Reports Account
    def add_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ADDUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request get_user_uri, 'post', options
    end
 
    # Remove the users from the Zoho Reports Account
    def remove_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'REMOVEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request get_user_uri, 'post', options
    end
 
    # Activate the users in the Zoho Reports Account
    def activate_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ACTIVATEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request get_user_uri, 'post', options
    end
 
    # Deactivate the users in the Zoho Reports Account
    def deactivate_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'DEACTIVATEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request get_user_uri, 'post', options
    end

    # Adds a row to the specified table identified by the URI
    def add_row(table_name, column_values)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ADDROW',
        },
        :body => column_values
      }

      send_request get_uri(table_name), 'post', options
    end
    
    # Update the data in the specified table identified by the URI.
    def update_data(table_name, column_values, criteria, config={})
      body = column_values.merge!({:ZOHO_CRITERIA => criteria})
      body = body.merge!(config) if config.any?

      options = {
        :query => {
          'ZOHO_ACTION' => 'UPDATE',
        },
        :body => body
      }

      send_request get_uri(table_name), 'post', options
    end

    # Delete the data in the specified table identified by the URI.
    def delete_data(table_name, criteria, config={})
      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'DELETE',
        },
        :body => body
      }

      send_request get_uri(table_name), 'post', options
    end

    # Export the data in the specified table identified by the URI.
    def export_data(table_or_report_name, format, criteria, config={})
      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'EXPORT',
          'ZOHO_OUTPUT_FORMAT' => format,
        },
        :body => body
      }

      result = send_request get_uri(table_or_report_name), 'post', options
      result
      # TODO: Figure out to what to do with File objects response
    end

    # Export the data with the specified SQL query identified by the URI.
    def export_data_using_sql(table_or_report_uri, format, sql, config={})
      body = {'ZOHO_SQLQUERY' => sql}
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'EXPORT',
          'ZOHO_OUTPUT_FORMAT' => format,
        },
        :body => body
      }

      result = send_request get_uri(table_or_report_name), 'post', options
      result
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Bulk import data into the table identified by the URI.
    def import_data(table_name, import_type, import_content, import_config={})
      raise "Import Type must be APPEND, TRUNCATEADD or UPDATEADD" unless ["APPEND", "TRUNCATEADD", "UPDATEADD"].include?(import_type)

      body = {
        'ZOHO_AUTO_IDENTIFY' => 'true',
        'ZOHO_ON_IMPORT_ERROR' => 'SETCOLUMNEMPTY',
        'ZOHO_CREATE_TABLE' => 'false',
        'ZOHO_IMPORT_TYPE' => import_type,
        'ZOHO_IMPORT_DATA' => import_content,
        'ZOHO_IMPORT_FILETYPE' => 'JSON',
        'ZOHO_DATE_FORMAT' => "yyyy/MM/dd HH:mm:ss Z",
        'ZOHO_MATCHING_COLUMNS' => 'id', 
      }
      puts body['ZOHO_IMPORT_DATA']
      body = body.merge!(import_config) if import_config.any?

      options = {
        :query => {
          'ZOHO_ACTION' => 'IMPORT',
        },
        :body => body
      }

      send_request get_uri(table_name), 'post', options
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Converts formats to appropriate JSON value that can be consumed by Zoho Reports
    # Hint, hint...datetimes
    def self.zoho_attributes(attributes)
      zohoified_attributes = Hash.new 

      attributes.map do |k,v| 
        if v.instance_of?(ActiveSupport::TimeWithZone)
          # Zoho doesn't currently deal well with JSON dates (particularly ones with milliseconds) so we'll convert to a string first
          zohoified_attributes[k] = v.strftime('%Y/%m/%d %T %Z')
          puts "#{k}: #{zohoified_attributes[k]}"
        else
          zohoified_attributes[k] = v
          puts "NOT TIME: #{k} - #{attributes[k].class}"
        end
      end

      return zohoified_attributes

    end

    # Returns the URI for the specified database table (or report).
    def get_uri(table_or_report_name)
      "/#{URI.encode ZohoReports.configuration.login_email}/#{URI.encode ZohoReports.configuration.zoho_database_name}/#{URI.encode table_or_report_name}"
    end        

    # Returns the URI for the specified database 
    def get_db_uri
      "#{URI.encode ZohoReports.configuration.login_email}/#{URI.encode ZohoReports.configuration.zoho_database_name}"
    end

    # Returns the URI for the specified user 
    def get_user_uri
      "/#{URI.encode ZohoReports.configuration.login_email}"
    end
  end
end