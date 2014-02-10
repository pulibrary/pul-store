require 'spec_helper'

describe "Lae::Folders" do

  describe "GET /lae/folders" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get lae_folders_path
      response.status.should be(200)
    end

  end

end
