require 'spec_helper'
include Warden::Test::Helpers


feature "attach a hard drive" do
  before(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::HardDrive.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  after(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::HardDrive.delete_all
    User.delete_all
  end

    scenario "Attach New Hard Drive Confirms Success", js: true do
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      box = boxes[rand(0..2)]
      login_as(@user, :scope => :user)
      visit edit_lae_box_path(box.id)
      click_link('Attach Drive to Box')
      #new_folder_modal = page.driver.window_handles.last
      #page.within_window new_folder_modal do
      within '#new-hard-drive-modal' do
        fill_in 'lae_hard_drive[barcode]', :with => TEST_BARCODES.pop
        click_button 'Attach Drive'
        page.should  have_css '#hard_drive_dialog_messages .alert-success'
      end
      
    end

    scenario "Invalid Drive Barcode Confirms Failure", js: true do
      # TESTME
      pending "Not sure duplicate barcode validation works here"
    end


end