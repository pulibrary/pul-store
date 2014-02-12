require 'spec_helper'

describe "Lae::FoldersController" do
  before(:all) do
    PulStore::Lae::Folder.delete_all
  end

  describe "GET /lae/folders" do
    it "works!" do
      get lae_folders_path
      response.status.should be(200)
    end
  end

  describe "POST /lae/folders" do
    it "Should create a new folder with valid attributes" do
      params = FactoryGirl.attributes_for(:lae_prelim_folder)
      post lae_folders_path, { lae_folder: params}
      response.status.should be(302)
    end

    it "Should create a new folder with valid attributes and be able to respond w/ JSON" do
      params = FactoryGirl.attributes_for(:lae_prelim_folder)
      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      response.status.should be(201)
      JSON.parse(response.body)['barcode'].should == params[:barcode].to_s
    end

    it "Should not allow us to make dupes (validations should be enforced" do
      params = FactoryGirl.attributes_for(:lae_prelim_folder)

      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      response.status.should be(201)
      JSON.parse(response.body)['barcode'].should == params[:barcode].to_s

      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      JSON.parse(response.body)['barcode'].should_not be_nil
    end
  end

end
