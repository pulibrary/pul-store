require 'spec_helper'

describe "PulStore::Lae::Genres" do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /lae/genres.json" do
    it "can get json" do
      login_as(@user, :scope => :user)
      get lae_genres_path format: :json
      response.status.should be(200)
      JSON.parse(response.body).any?{ |a| a['pul_label'] == 'Maps' }.should be_true
    end
  end
end
