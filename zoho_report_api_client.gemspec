# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zoho_report_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = "zoho_report_api_client"
  spec.version       = ZohoReportApiClient::VERSION
  spec.authors       = ["Neil Giarratana"]
  spec.email         = ["neil@scorebrd.com"]
  spec.summary       = ["Wrapper for Zoho Reports API"]
  spec.description   = ["Wraps the raw HTTP based API of Zoho Reports with easy to use methods for the ruby platform. This enables ruby and Rails developers to easily use Zoho Reports API."]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency "httparty"
end
