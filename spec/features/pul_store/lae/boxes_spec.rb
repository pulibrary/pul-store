require 'spec_helper'
include Warden::Test::Helpers


feature "boxes" do
  before(:all) do
    PulStore::Lae::Box.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  after(:all) do
    PulStore::Lae::Box.delete_all
    User.delete_all
  end

  feature "I am not allowed to be a lae box editor" do
    before(:all) do
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      visit edit_lae_box_path(boxes[0].id)
    end

    scenario "When I visit a URL to edit a box I see a message advising me to sign in" do
      page.should_not have_content "Sign In"
    end
  end

  feature "I am allowed lae box editor" do
    before(:all) do
      # barcodes = Array.new(3) { TEST_BARCODES.pop }
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      login_as(@user, :scope => :user)
      visit lae_boxes_path
    end

    scenario "I should see boxes to edit" do
      page.should have_content "Edit"
      #Warden.test_reset!
    end
  end

  feature "quick lookup by barcode" do

    scenario "finds the correct box" do
      boxes = Array.new(3) do |b|
        FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop )
      end
      box = boxes[rand(0..2)]
      login_as(@user, :scope => :user)
      visit lae_boxes_path

      within('form#quick_lookup') do
        fill_in 'barcode', with: box.barcode
        click_on('quick_lookup_submit')
      end
      current_url.should == url_for(box)
      #Warden.test_reset!
    end

    scenario "redirects to the boxes path flashes a message when the box can't be found" do
      bad_barcode = 'not a barcode'
      login_as(@user, :scope => :user)
      visit lae_boxes_path

      within('form#quick_lookup') do
        fill_in 'barcode', with: bad_barcode
        click_on('quick_lookup_submit')
      end
      current_url.should == lae_boxes_url

      page.should have_selector ".alert"
      #Warden.test_reset!
    end
  end

  feature "Friendly barcode uniqueness" do

    scenario "Page offers a link to the existing box when a duplicate barcode is entered" do
      pending "Implement me when we have #new method"
      # barcode = TEST_BARCODES.pop
      # FactoryGirl.create(:lae_box, barcode: barcode)

      # visit lae_boxes_path

      # within('form#quick_lookup') do
      #   fill_in 'barcode', with: barcode
      #   click_on('quick_lookup_submit')
      # end
      # current_url.should == lae_boxes_url
      # puts page.first(:css, '.alert').text
    end

  end
end
