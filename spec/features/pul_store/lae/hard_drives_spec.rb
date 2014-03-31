require 'spec_helper'
include Warden::Test::Helpers

feature "boxes" do
  before(:all) { PulStore::Lae::Box.delete_all }
  after(:all) { PulStore::Lae::Box.delete_all }
  before(:all) { PulStore::Lae::HardDrive.delete_all }
  after(:all) { PulStore::Lae::HardDrive.delete_all }

  feature "box and drive associations by barcode" do
    before(:all) do
      @drive = FactoryGirl.create(:lae_hard_drive)
      User.delete_all
      @user = FactoryGirl.create(:user)
      @user.save!
    end

    after(:all) do
      User.delete_all
    end

    scenario "a box that exists can be associated with a drive" do
      box = FactoryGirl.create(:lae_box)
      login_as(@user, :scope => :user)
      visit edit_lae_hard_drive_path(@drive)

      within("form.edit_lae_hard_drive") do
        fill_in 'box_barcode', with: box.barcode
        click_on('hard_drive_submit')
      end
      current_url.should == url_for(@drive)
    end

    scenario "an association with a box can be removed by checking a box" do
      unused_barcode = TEST_BARCODES.shift
      login_as(@user, :scope => :user)
      visit edit_lae_hard_drive_path(@drive)

      within("form.edit_lae_hard_drive") do
        fill_in 'box_barcode', with: unused_barcode
        click_on('hard_drive_submit')
      end
      current_url.should == lae_hard_drive_url(@drive)
    end

    scenario "the box association can be cleared" do
      box = FactoryGirl.create(:lae_box)
      @drive.box = box
      @drive.save!
      login_as(@user, :scope => :user)
      visit edit_lae_hard_drive_path(@drive)

      within('form.edit_lae_hard_drive') do
        check('lae_hard_drive_remove_box')
        click_on('hard_drive_submit')
      end

      find('#box_barcode').text.should == 'None'
      current_url.should == lae_hard_drive_url(@drive)
    end

  end

end
