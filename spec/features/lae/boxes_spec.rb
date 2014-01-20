require 'spec_helper'

feature "boxes" do
  before(:all) { PulStore::Lae::Box.delete_all }
  after(:all) { PulStore::Lae::Box.delete_all }
  
  feature "quick lookup by barcode" do
    before(:all) do
      @test_barcodes = Rails.application.config.barcode_list
    end

    scenario "finds the correct box" do
      # barcodes = Array.new(3) { @test_barcodes.pop }
      boxes = Array.new(3) do |b| 
        FactoryGirl.create(:lae_box, barcode: @test_barcodes.pop )
      end
      box = boxes[rand(0..2)]

      visit lae_boxes_path

      within('form#quick_lookup') do
        fill_in 'barcode', with: box.barcode
        click_on('quick_lookup_submit')
      end
      current_url.should == url_for(box)
    end

    scenario "redirects to the boxes path flashes a message when the box can't be found" do
      bad_barcode = 'not a barcode'
      visit lae_boxes_path

      within('form#quick_lookup') do
        fill_in 'barcode', with: bad_barcode
        click_on('quick_lookup_submit')
      end
      current_url.should == lae_boxes_url

      page.should have_selector ".alert"
    end
  end

  feature "Friendly barcode uniqueness" do

    scenario "Page offers a link to the existing box when a duplicate barcode is entered" do
      pending "Implement me when we have #new method"
      # barcode = @test_barcodes.pop
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
