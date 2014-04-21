# ZohoReports

Wraps the raw HTTP based API of Zoho Reports with easy to use methods for the ruby platform. This enables ruby and Rails developers to easily use Zoho Reports API.

## Installation

Add this line to your application's Gemfile:

    gem 'zoho_reports', :git => "https://github.com/neilsmind/zoho_reports"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zoho_reports

## Usage

### Setting auth_token and login_email
```ruby
# (usually in /config/intializers/zoho_reports.rb)
ZohoReports.configure do |config|
  config.auth_token = 'token'
  config.login_email = 'user@example.com'
  config.database_name = 'test_database'
end
```

### Initializing an instance
```ruby
client = ZohoReports::Client.new
```

### Importing an entire model
This example shows how to import the "Widget" model records, including creating a table if it doesn't already exist. 

```ruby
# Notice the ZOHO_DATE_FORMAT here
client.import_data(
  "test_database", 
  "widgets", 
  'UPDATEADD', 
  Widget.all.to_json, 
  'ZOHO_MATCHING_COLUMNS' => 'id', 
  'ZOHO_CREATE_TABLE' => 'true', 
)

```

When importing through the API and generating a new table, string and datetime date types import correctly with format. However, here are the steps provided through the [Zoho Reports wiki comments](https://zohoreportsapi.wiki.zoho.com/importing-bulk-data.html) in case you have an issue with the column format:

1. Login into Zoho Reports, Open the import wizard ( "Import Excel, CSV, HTML, Google docs,.." ), upload your file.
2. Click "Next" button to go to the next screen of import wizard (i.e step 2 of 2), there you can see the preview table. 
3. In that table, the first row will be header row ( i.e., Column names ) and the second row will be the datatype which is auto identified by our Zoho Reports system. There you can change the column datatype to "Text" for the column you want to change. Then, continue the import process.

### Rails / ActiveRecord Support
ZohoReports includes a module specific to ActiveReports that may be used as follows:

```ruby
# /app/models/widget.rb
class Widget < ActiveRecord::Base
  zoho_reportify
...
end
```

This adds two things to your Rails app.
1. Widget.intialize_zoho_table will create the database table based on Widget.table_name and load all of the current data into it
2. Adds an after_save callback that stores the instance attributes into the Zoho Reports table keeping your data in sync

## Contributing

1. Fork it ( http://github.com/<my-github-username>/zoho_reports/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
