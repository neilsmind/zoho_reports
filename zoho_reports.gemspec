# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zoho_reports/version'

Gem::Specification.new do |spec|
  spec.name          = "zoho_reports"
  spec.version       = ZohoReports::VERSION
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
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "spring"
  spec.add_development_dependency "sqlite3"
  spec.add_dependency "rails"
  spec.add_dependency "addressable"
  spec.add_dependency "httmultiparty"
end
