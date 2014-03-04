require 'spec_helper'

describe "Lae::BoxesController" do

  describe "GET /lae/boxes" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get lae_boxes_path
      response.status.should be(200)
    end

  end

end
