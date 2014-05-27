module ZohoReports
  class Configuration
    attr_accessor :login_email, :auth_token, :zoho_database_name

    def initialize
      @login_email = ''
      @auth_token = ''
      @zoho_database_name = ''
      @environments = ['production']
    end
  end
end