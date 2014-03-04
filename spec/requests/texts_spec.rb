require 'spec_helper'

describe "Texts" do
  describe "GET /texts" do

    it "works!" do
      get texts_path
      response.status.should be(200)
    end

  end
end
