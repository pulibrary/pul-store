require 'spec_helper'

describe "PulStore::Lae::Genres" do
  describe "GET /pul_store_lae_genres" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get pul_store_lae_genres_path
      response.status.should be(200)
    end
  end
end
