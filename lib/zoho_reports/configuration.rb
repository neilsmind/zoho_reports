module ZohoReports
  class Configuration
    attr_accessor :login_email, :auth_token

    def initialize
      @login_email = ''
      @auth_token = ''
    end
  end
end