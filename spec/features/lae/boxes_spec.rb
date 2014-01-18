require 'spec_helper'

feature "quick lookup by barcode" do
  before(:all) do
    PulStore::Lae::Box.delete_all
    barcodes_fp = Rails.root.join('spec/fixtures/test_barcodes.yml')
    @test_barcodes = YAML.load_file(barcodes_fp)
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
