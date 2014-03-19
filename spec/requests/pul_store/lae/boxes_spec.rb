require 'spec_helper'

describe "Lae::BoxesController" do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /lae/boxes" do
    it "works!" do
      login_as(@user, :scope => :user)
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get lae_boxes_path
      response.status.should be(200)
    end

  end

end
