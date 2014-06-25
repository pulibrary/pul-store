require 'spec_helper'



describe "Texts", :type => :request do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /texts" do

    it "works!" do
      login_as(@user, :scope => :user)
      get texts_path
      expect(response.status).to be(200)
    end

  end
end
