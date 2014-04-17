require "zoho_report_api_client/version"
require "uri"
require "HTTParty"

module ZohoReportApiClient
  class ReportClient
    include HTTParty
    # ZohoReportAPIClient provides the python based language binding to the http based api of ZohoReports.

    attr_accessor :authtoken, :login_email, :api_version

    base_uri "reportsapi.zoho.com:443/api"

    def initialize(login_email,authtoken)
      self.authtoken = authtoken
      self.login_email = login_email
      self.api_version = '1.0'
    end

    def default_query
      {
        'authtoken' => self.authtoken,
        'ZOHO_OUTPUT_FORMAT' => 'JSON',
        'ZOHO_ERROR_FORMAT' => 'JSON',
        'ZOHO_API_VERSION' => self.api_version,
      }
    end

    def send_request(url, http_method, options)
      dq = default_query

      # Merge our default query string values with the specificed query values
      options[:query] = dq.merge!(options[:query])

      response = self.class.send(http_method,url, options)

      if response.success?
        response
      else
        raise response.response
      end
    end

    # Gets copy database key for specified database identified by the URI    
    def get_copy_db_key(db_uri)
      # payLoad = ReportClientHelper.getAsPayLoad([config],None,None)
      options = {
        :query => { 'ZOHO_ACTION' => 'GETCOPYDBKEY' }
      } 

      send_request(db_uri, 'post', options)
    end

    # Copy the specified database identified by the URI
    def copy_database(db_uri)
      options = {
        :query => { 'ZOHO_ACTION' => 'COPYDATABASE' }
      }

      send_request(db_uri, 'post', options)
    end

    # Delete the specified database
    def delete_database(database_name)
      options = {
        :query => {
          'ZOHO_ACTION' => 'DELETEDATABASE',
          'ZOHO_DATABASE_NAME' => database_name,
        }
      }
      send_request(user_uri, 'post', options)
    end
 
    # Add the users to the Zoho Reports Account
    def add_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ADDUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request(user_uri, 'post', options)
    end
 
    # Remove the users from the Zoho Reports Account
    def remove_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'REMOVEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request(user_uri, 'post', options)
    end
 
    # Activate the users in the Zoho Reports Account
    def activate_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ACTIVATEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request(user_uri, 'post', options)
    end
 
    # Deactivate the users in the Zoho Reports Account
    def deactivate_user(email_ids)
      options = {
        :query => {
          'ZOHO_ACTION' => 'DEACTIVATEUSER',
          'ZOHO_EMAILS' => email_ids,
        }
      }

      send_request(user_uri, 'post', options)
    end

    # Adds a row to the specified table identified by the URI
    def add_row(table_uri, column_values)
      options = {
        :query => {
          'ZOHO_ACTION' => 'ADDROW',
        },
        :body => column_values
      }

      send_request(table_uri, 'post', options)
    end
    
    # Update the data in the specified table identified by the URI.
    def update_data(table_uri, column_values, criteria, config={})
      body = column_values.merge!({'ZOHO_CRITERIA' => criteria})
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'UPDATE',
        },
        :body => body
      }

      send_request(table_uri, 'post', options)
    end

    # Delete the data in the specified table identified by the URI.
    def delete_data(table_uri, criteria, config={})
      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'DELETE',
        },
        :body => body
      }

      send_request(table_uri, 'post', options)
    end

    # Export the data in the specified table identified by the URI.
    def export_data(table_or_report_uri, format, criteria, config={})
      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'EXPORT',
          'ZOHO_OUTPUT_FORMAT' => format,
        },
        :body => body
      }

      send_request(table_or_report_uri, 'post', options)
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

      send_request(table_or_report_uri, 'post', options)
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Bulk import data into the table identified by the URI.
    def import_data(table_uri, import_type, import_content, import_config={})
      raise "Import Type must be APPEND, TRUNCATEADD or UPDATEADD" unless  ["APPEND", "TRUNCATEADD", "UPDATEADD"].include?(import_type)

      body = {
        'ZOHO_AUTO_IDENTIFY' => 'true',
        'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
        'ZOHO_CREATE_TABLE' => 'false',
        'ZOHO_IMPORT_TYPE' => import_type,
        'ZOHO_IMPORT_DATA' => importContent,
      }
      body = body.merge!(import_config) if import_config.present?

      options = {
        :query => {
          'ZOHO_ACTION' => 'EXPORT',
          'ZOHO_OUTPUT_FORMAT' => format,
        },
        :body => body
      }

      send_request(table_or_report_uri, 'post', options)
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Returns the URI for the specified database table (or report).
    def get_uri(db_name, table_or_report_name)
      "/#{URI.encode self.login_email}/#{URI.encode db_name}/#{URI.encode table_or_report_name}"
    end        

    # Returns the URI for the specified database 
    def get_db_uri(db_name)
      "#{URI.encode self.login_email}/#{URI.encode db_name}"
    end

    # Returns the URI for the specified user 
    def get_user_uri()
      "/#{URI.encode self.login_email}"
    end
  end

end
