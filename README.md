# ZohoReportApiClient

Wraps the raw HTTP based API of Zoho Reports with easy to use methods for the ruby platform. This enables ruby and Rails developers to easily use Zoho Reports API.

## Installation

Add this line to your application's Gemfile:

    gem 'zoho_report_api_client', :git => "https://github.com/neilsmind/zoho_report_api_client"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zoho_report_api_client

## Usage

### Initializing an instance
```ruby
client = ZohoReportApiClient::Client.new(login_email: 'user@example.com',auth_token: '_000000000000000000000000_')
```

### Importing an entire model
This example shows how to import the "Widget" model records, including creating a table if it doesn't already exist. 

```ruby
# Zoho Reports doesn't support standard json date/time formats so we temporarily turn it off
ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

# Notice the ZOHO_DATE_FORMAT here
client.import_data("test_database", "widgets", 'UPDATEADD', Widget.all.to_json, 'ZOHO_MATCHING_COLUMNS' => 'id', 'ZOHO_CREATE_TABLE' => 'true', 'ZOHO_DATE_FORMAT' => 'yyyy/MM/dd HH:mm:ss Z')

# Turn standard json back on
ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/zoho_report_api_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
