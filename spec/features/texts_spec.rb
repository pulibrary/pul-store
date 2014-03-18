require 'spec_helper'

feature "uploading pages" do

  before(:all) do
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  scenario "uploads file" do
    login_as(@user, :scope => :user)
    visit new_text_path

    within('form#fileupload') do
      attach_file('text_pages', File.join(Rails.root, 'spec/fixtures/files/00000001.tif'))
      click_on('upload')
    end

  end

end
