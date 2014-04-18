require 'zoho_reports'
require 'webmock/rspec'
require 'addressable/uri'
require 'json'

WebMock.disable_net_connect!(allow_localhost: true)

def stub_zoho_request(action, path, zoho_action, options = {})
  response_filename = options.delete :response_filename
  status = options.delete(:status) || 200
  query = options.delete(:query) || {}

  stub_request(action, "https://reportsapi.zoho.com/api/#{@client.login_email}/#{path}")
    .with(options.merge(
        :query => query.merge({
                    "ZOHO_ACTION" => zoho_action, 
                    'authtoken' => @client.auth_token,
                    'ZOHO_OUTPUT_FORMAT' => 'JSON',
                    'ZOHO_ERROR_FORMAT' => 'JSON',
                    'ZOHO_API_VERSION' => '1.0'})
    ))
    .to_return(:body => File.new("spec/fixtures/#{response_filename}"), :status => status)
end

def query_string(values)
  uri = Addressable::URI.new
  uri.query_values = values
  uri.query
end
