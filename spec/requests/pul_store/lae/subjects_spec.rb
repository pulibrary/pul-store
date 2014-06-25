require 'spec_helper'

describe "PulStore::Lae::Subject", :type => :request do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET" do
    category = PulStore::Lae::Category.find_by(label: "Urban issues")
    category_subject_path = "/lae/categories/#{category.id}/subjects"
    subject = PulStore::Lae::Subject.find_by(label: "Urban-rural migration")
    
    it "can serve subjects for a category as json" do
      login_as(@user, :scope => :user)
      get category_subject_path, format: :json
      expect(response.status).to be(200)
      expect(JSON.parse(response.body).any?{ |a| a['label'] == subject.label }).to be_truthy
    end

    it "redirects requests without .json to .json" do
      login_as(@user, :scope => :user)
      get category_subject_path
      expect(response.status).to be(301)
      # JSON.parse(response.body).any?{ |a| a['label'] == subject.label }.should be_true
    end
  end
end

