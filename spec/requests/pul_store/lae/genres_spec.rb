require 'spec_helper'

describe "PulStore::Lae::Genres" do
  describe "GET /lae/genres.json" do
    it "can get json" do
      get lae_genres_path format: :json
      response.status.should be(200)
    end
  end
end
