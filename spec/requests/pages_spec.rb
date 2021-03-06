require 'spec_helper'
include Warden::Test::Helpers

describe "Pages", :type => :request do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /pages" do
    it "works!" do
      login_as(@user, :scope => :user)
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get pages_path
      expect(response.status).to be(200)
    end

  end

end
