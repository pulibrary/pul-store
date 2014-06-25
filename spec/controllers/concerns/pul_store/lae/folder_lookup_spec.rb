require 'spec_helper'
include Warden::Test::Helpers
include PulStore::Lae::FolderLookups

describe PulStore::Lae::FolderLookups, :type => :controller do
  before(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::Folder.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "Number of Folders attached to Box" do
    before(:all) do
      @box = FactoryGirl.create(:lae_box_with_prelim_folders, barcode: TEST_BARCODES.pop )
    end

    it "Folder Count by Box should be Equal from Fedora and Solr" do
      folder_list = get_folder_list_by_box(@box.id)
      expect(@box.folders.size).to eq(get_folder_list_by_box(@box.id).length)
    end
  end

end