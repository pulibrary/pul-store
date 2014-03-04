require 'spec_helper'

feature "boxes" do
  before(:all) { PulStore::Lae::Box.delete_all }
  after(:all) { PulStore::Lae::Box.delete_all }
  before(:all) { PulStore::Lae::HardDrive.delete_all }
  after(:all) { PulStore::Lae::HardDrive.delete_all }
  
  feature "box and drive associations by barcode" do
    before(:all) do
      @test_barcodes = Rails.application.config.barcode_list
      @drive = FactoryGirl.create(:lae_hard_drive)
    end

    scenario "a box that exists can be associated with a drive" do
      box = FactoryGirl.create(:lae_box)

      visit edit_lae_hard_drive_path(@drive)

      within("form.edit_lae_hard_drive") do
        fill_in 'box_barcode', with: box.barcode
        click_on('hard_drive_submit')
      end
      current_url.should == url_for(@drive)
    end

    scenario "an association with a box can be removed by checking a box" do
      unused_barcode = @test_barcodes.shift

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
