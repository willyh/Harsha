require 'spec_helper'

describe PaymentNotificationController do

  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

end
