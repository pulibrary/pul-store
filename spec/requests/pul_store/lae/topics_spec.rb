require 'spec_helper'

describe "PulStore::Lae::Topic" do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET" do
    it "can serve topics for a subject as json" do
      login_as(@user, :scope => :user)
      subject = PulStore::Lae::Subject.find_by(value: "Arts and culture")
      subject_topics_path = "/lae/subjects/#{subject.id}/topics"
      get subject_topics_path, format: :json
      response.status.should be(200)
      JSON.parse(response.body).any?{ |a| a['value'] == 'Music' }.should be_true
    end
  end
end

