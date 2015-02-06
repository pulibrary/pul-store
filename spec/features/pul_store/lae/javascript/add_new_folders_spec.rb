require 'spec_helper'
include Warden::Test::Helpers


feature "add new folders" do
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

  feature "Add New Folder using Modal" do
    scenario "New Folder Form Confirms Successful Save", js: true do
      skip("Passing locally but travis repeatedly throws errors") if ENV["CI"]
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      box = boxes[rand(0..2)]
      login_as(@user, :scope => :user)
      visit edit_lae_box_path(box.id)
      click_link('Add Folder to Box')
      #new_folder_modal = page.driver.window_handles.last
      #page.within_window new_folder_modal do
      within '#new-folder-modal' do
        fill_in 'lae_folder[barcode]', :with => TEST_BARCODES.pop
        fill_in 'lae_folder[physical_number]', :with => 2
        select "Manuscripts", :from => "lae_folder[genre]"
        fill_in 'lae_folder[page_count]', :with => 15
        click_button 'Create Folder'
        expect(page).to have_content 'Folder 2'
      end
      
    end

    scenario "New Folder Form Confirms Invalid Save", js: true do
      #skip("Passing locally but travis repeatedly throws errors") if ENV["CI"]
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      box = boxes[rand(0..2)]
      login_as(@user, :scope => :user)
      visit edit_lae_box_path(box.id)
      click_link('Add Folder to Box')
      #new_folder_modal = page.driver.window_handles.last
      #page.within_window new_folder_modal do
      within '#new-folder-modal' do
        fill_in 'lae_folder[barcode]', :with => TEST_BARCODES.pop
        fill_in 'lae_folder[physical_number]', :with => "two"
        select "Manuscripts", :from => "lae_folder[genre]"
        fill_in 'lae_folder[page_count]', :with => "fifteen"
        click_button 'Create Folder'
        expect(page).not_to have_content 'Folder 2'
      end
      
    end

  end

end
