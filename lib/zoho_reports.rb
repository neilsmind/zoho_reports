require "zoho_reports/version"
require "zoho_reports/client"
require "zoho_reports/configuration"

module ZohoReports
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

end
