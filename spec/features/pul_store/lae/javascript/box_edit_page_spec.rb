require 'spec_helper'
include Warden::Test::Helpers

feature 'Box Page Should Display Attached Folders' do
  before(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::Folder.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  after(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::Folder.delete_all
    User.delete_all
  end

  scenario "When I load the Folder Page I See should see an edit row for each attached folder", js: true do
    boxes = Array.new(3) do |b|
      FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
    end
    box = boxes[rand(0..2)]
    folders = Array.new(21) do |f|
      #:lae_core_folder
      FactoryGirl.create(:lae_core_folder, box: box, barcode: TEST_BARCODES.pop )
    end
    login_as(@user, :scope => :user)
    visit edit_lae_box_path(box.id)
    expect(page).to have_xpath('//table/tbody/tr', :count => 21)

  end

  # Now showing all folders 
  # scenario "When I Click the See all Folders Button I should see all attached Folders", js: true do
  #   #skip("Passing locally but travis repeatedly throws errors") if ENV["CI"]
  #   boxes = Array.new(3) do |b|
  #     FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
  #   end
  #   box = boxes[rand(0..2)]
  #   folders = Array.new(21) do |f|
  #     #:lae_core_folder
  #     FactoryGirl.create(:lae_core_folder, box: box, barcode: TEST_BARCODES.pop )
  #   end
  #   login_as(@user, :scope => :user)
  #   visit edit_lae_box_path(box.id)
  #   click_link('Show All Folders')
  #   expect(page).to have_xpath('//table/tbody/tr', :count => 21)

  # end

end