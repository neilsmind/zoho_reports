require "zoho_report_api_client/version"
require "uri"

module ZohoReportApiClient
  class ReportClient
    # ZohoReportAPIClient provides the python based language binding to the http based api of ZohoReports.

    def init(login_email, authtoken):
      # Creates a new C{ReportClient} instance.
      # @param authtoken: User's authtoken.
      # @type authtoken:string
      self.iam_server_url = "https://accounts.zoho.com"
      self.report_server_url = "https://reportsapi.zoho.com/api"
      self.authtoken = authtoken
      self.login_email = login_email
      self.api_version = '1.0'
      self.default_query = {
        'authtoken' => self.authtoken,
        'ZOHO_OUTPUT_FORMAT' => 'JSON',
        'ZOHO_ERROR_FORMAT' => 'JSON',
        'ZOHO_API_VERSION' => self.api_version,
      }
    end

    def send_request(url, http_method, query, options={})
      query = self.default_query.merge!(query)
      response = self.class.send(http_method, "#{self.report_server_url}/#{login_email}/#{url}", options)

      if response.success?
        response
      else
        raise response.response
      end
    end

    # Gets copy database key for specified database identified by the URI    
    def get_copy_db_key(db_uri)
      # payLoad = ReportClientHelper.getAsPayLoad([config],None,None)
      query = {
        'ZOHO_ACTION' => 'GETCOPYDBKEY',
      }

      send_request(db_uri, 'post', query)
    end

    # Copy the specified database identified by the URI
    def copy_database(db_uri)
      query = {
        'ZOHO_ACTION' => 'COPYDATABASE',
      }
      send_request(db_uri, 'post', query)
    end

    # Delete the specified database
    def delete_database(database_name)
      query = {
        'ZOHO_ACTION' => 'DELETEDATABASE',
        'ZOHO_DATABASE_NAME' => database_name,
      }
      send_request(user_uri, 'post', query)
    end
 
    # Add the users to the Zoho Reports Account
    def add_user(email_ids)
      query = {
        'ZOHO_ACTION' => 'ADDUSER',
        'ZOHO_EMAILS' => email_ids,
      }

      send_request(user_uri, 'post', query)
    end
 
    # Remove the users from the Zoho Reports Account
    def remove_user(email_ids)
      query = {
        'ZOHO_ACTION' => 'REMOVEUSER',
        'ZOHO_EMAILS' => email_ids,
      }

      send_request(user_uri, 'post', query)
    end
 
    # Activate the users in the Zoho Reports Account
    def activate_user(email_ids)
      query = {
        'ZOHO_ACTION' => 'ACTIVATEUSER',
        'ZOHO_EMAILS' => email_ids,
      }

      send_request(user_uri, 'post', query)
    end
 
    # Deactivate the users in the Zoho Reports Account
    def deactivate_user(email_ids)
      query = {
        'ZOHO_ACTION' => 'DEACTIVATEUSER',
        'ZOHO_EMAILS' => email_ids,
      }

      send_request(user_uri, 'post', query)
    end

    # Adds a row to the specified table identified by the URI
    def add_row(table_uri, column_values)
      query = {
        'ZOHO_ACTION' => 'ADDROW',
      }

      send_request(table_uri, 'post', query, body: body)
    end
    
    # Update the data in the specified table identified by the URI.
    def update_row(table_uri, column_values, criteria, config={})
      query = {
        'ZOHO_ACTION' => 'UPDATE',
      }

      body = column_values.merge!({'ZOHO_CRITERIA' => criteria})
      body = body.merge!(config) if config.present?

      send_request(table_uri, 'post', query, body: body)
    end

    # Delete the data in the specified table identified by the URI.
    def update_row(table_uri, column_values, criteria, config={})
      query = {
        'ZOHO_ACTION' => 'DELETE',
      }

      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      send_request(table_uri, 'post', query, body: body)
    end

    # Export the data in the specified table identified by the URI.
    def export_data(table_or_report_uri, format, criteria, config={})
      query = {
        'ZOHO_ACTION' => 'EXPORT',
        'ZOHO_OUTPUT_FORMAT' => format,
      }

      body = {'ZOHO_CRITERIA' => criteria}
      body = body.merge!(config) if config.present?

      send_request(table_or_report_uri, 'post', query, body: body)
      # TODO: Figure out to what to do with File objects response
    end

    # Export the data with the specified SQL query identified by the URI.
    def export_data_using_sql(table_or_report_uri, format, sql, config={})
      query = {
        'ZOHO_ACTION' => 'EXPORT',
        'ZOHO_OUTPUT_FORMAT' => format,
      }

      body = {'ZOHO_SQLQUERY' => sql}
      body = body.merge!(config) if config.present?

      send_request(table_or_report_uri, 'post', query, body: body)
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Bulk import data into the table identified by the URI.
    def import_data(table_uri, import_type, import_content, import_config={})
      raise "Import Type must be APPEND, TRUNCATEADD or UPDATEADD" unless  ["APPEND", "TRUNCATEADD", "UPDATEADD"].include?(import_type)

      query = {
        'ZOHO_ACTION' => 'EXPORT',
        'ZOHO_OUTPUT_FORMAT' => format,
      }

      body = {
        'ZOHO_AUTO_IDENTIFY' => 'true',
        'ZOHO_ON_IMPORT_ERROR' => 'ABORT',
        'ZOHO_CREATE_TABLE' => 'false',
        'ZOHO_IMPORT_TYPE' => import_type,
        'ZOHO_IMPORT_DATA' => importContent,
      }
      body = body.merge!(import_config) if import_config.present?

      send_request(table_or_report_uri, 'post', query, body: body)
      # TODO: Figure out to what to do with File objectsw response
    end        

    # Returns the URI for the specified database table (or report).
    def get_uri(db_owner_name, db_name, table_or_report_name)
      "#{self.report_server_url}/api/#{URI.encode db_owner_name}/#{URI.encode db_name}/#{URI.encode table_or_report_name}"
    end        

    # Returns the URI for the specified database 
    def get_db_uri(db_owner_name, db_name)
      "#{self.report_server_url}/api/#{URI.encode db_owner_name}/#{URI.encode db_name}"
    end

    # Returns the URI for the specified user 
    def get_user_uri(db_owner_name)
      "#{self.report_server_url}/api/#{URI.encode db_owner_name}"
    end

end
