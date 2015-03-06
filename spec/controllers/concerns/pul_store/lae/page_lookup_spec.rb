require 'spec_helper'
include Warden::Test::Helpers
include PulStore::Lae::PageLookups

describe PulStore::Lae::PageLookups, :type => :controller do
  before(:all) do
    PulStore::Lae::Box.delete_all
    PulStore::Lae::Folder.delete_all
    PulStore::Page.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "Number of Pages attached to Folder" do
    before(:all) do
      @box = FactoryGirl.create(:lae_box_with_core_folders_with_pages, barcode: TEST_BARCODES.pop )
    end

    it "Page Count by Folder should be Equal from Fedora and Solr" do
      #skip "Add test to retrive pages by folder from solr"
      folders = @box.folders
      f = PulStore::Lae::Folder.find(folders[0].id)
      expect(f.pages.size).to eq(get_pages_by_folder(folders[0].id).size)
    end

  end

end