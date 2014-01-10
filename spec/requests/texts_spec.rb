require 'spec_helper'

describe "Texts" do
  describe "GET /texts" do

    # TODO: These are Integration tests and we should probably prefer them over
    # straight view testing. 
    # See http://everydayrails.com/2012/04/24/testing-series-rspec-requests.html

    it "works!" do
      get pul_store_texts_path
      response.status.should be(200)
    end

    it "uploads file" do
      visit new_pul_store_text_path

      within('form#fileupload') do
        attach_file('pul_store_text_pages', File.join(Rails.root, 'spec/fixtures/files/00000001.tif'))
        click_on('upload')
      end

    end

  end
end
