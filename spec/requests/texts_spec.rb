require 'spec_helper'



describe "Texts" do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /texts" do

    it "works!" do
      login_as(@user, :scope => :user)
      get texts_path
      response.status.should be(200)
    end

  end
end
