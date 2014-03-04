require 'spec_helper'

describe "Pages" do

  describe "GET /pages" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get pages_path
      response.status.should be(200)
    end

  end

end
