require 'spec_helper'

describe "Texts" do
  describe "GET /texts" do

    # TODO: These are Integration tests and we should probably prefer them over
    # straight view testing. 
    # See http://everydayrails.com/2012/04/24/testing-series-rspec-requests.html

    it "works!" do
      get texts_path
      response.status.should be(200)
    end

    it "uploads file" do
      visit texts_url
      page.should have_content('New Text')
      within('form') do
        #attach_file('text_pages', File.join(Rails.root, 'spec/fixtures/files/00000001.tif'))
      end
      #click_on('submit')
    end

  end
end
