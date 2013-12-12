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
  end
end
