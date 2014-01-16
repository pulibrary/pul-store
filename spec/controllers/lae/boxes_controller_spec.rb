require 'spec_helper'

describe Lae::BoxesController do

  let(:valid_attributes) { FactoryGirl.attributes_for :lae_box }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all boxes as @boxes" do
      PulStore::Lae::Box.delete_all 
      box = PulStore::Lae::Box.create! valid_attributes
      get :index, {}, valid_session
      assigns(:boxes).should eq([box])
    end
  end

end
