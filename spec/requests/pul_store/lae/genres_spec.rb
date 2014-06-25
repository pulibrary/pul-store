require 'spec_helper'

describe "PulStore::Lae::Genres", :type => :request do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /lae/genres.json" do
    it "can get json" do
      login_as(@user, :scope => :user)
      get lae_genres_path format: :json
      expect(response.status).to be(200)
      expect(JSON.parse(response.body).any?{ |a| a['pul_label'] == 'Maps' }).to be_truthy
    end
  end
end
