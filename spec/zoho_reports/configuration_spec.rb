require "spec_helper"

module ZohoReports
  describe Configuration do
    describe "#auth_token" do
      it "default value is nil" do 
        expect(Configuration.new.auth_token).to eq('')
      end
    end

    describe "#auth_token=" do 
      it "can set value" do
        config = Configuration.new
        config.auth_token = 'token'
        expect(config.auth_token).to eq('token')
      end
    end
  end
end