require 'spec_helper'

describe PulStore::Page do

  it_behaves_like "supports characterization"

  it "has a valid factory" do
    FactoryGirl.create(:page).should be_valid
  end

  it "gets a pid that is a NOID" do
    p = FactoryGirl.create(:page)
    p.pid.start_with?(PUL_STORE_CONFIG['id_namespace']).should be_true
  end

  it "has a sort_order" do
    FactoryGirl.build(:page, sort_order: nil).should_not be_valid
  end

  it "can have a float as a sort_order" do
    FactoryGirl.build(:page, sort_order: 4.1).should be_valid
  end

  it "can take a master image" do
    p = FactoryGirl.build(:page)
    p.save
    p.datastreams.keys.include?('masterImage').should be_true
  end

  it "can populate its master_* fields from fits XML" do
    sample_fits_fp = File.join(RSpec.configuration.fixture_path, 'files', 'fits.xml')
    p = FactoryGirl.build(:page)
    p.master_tech_md = File.read(sample_fits_fp)
    p.master_mime_type.should == "image/tiff"
  end

  describe "belongs to a parent PulStore::Lae::Folder or PulStore::Text" do
    before(:all) do
      PulStore::Project.delete_all
      PulStore::Page.delete_all
      PulStore::Lae::Box.delete_all
      PulStore::Lae::Folder.delete_all

      @project = FactoryGirl.create(:project)
      @box = FactoryGirl.create(:lae_box, project: @project)
      @folder = FactoryGirl.create(:lae_core_folder, box: @box, project: @project)
      @text = FactoryGirl.create(:text, project: @project)
    end

    describe "can make the association via an alias" do
      it "#folder" do
        page = FactoryGirl.create(:page, folder: @folder, project: @project)
        @folder.reload
        page.folder.should == @folder
        @folder.pages.should include(page)
      end

      it "#text" do
        page = FactoryGirl.create(:page, text: @text, project: @project)
        @text.reload
        page.text.should == @text
        @text.pages.should include(page)
      end
    end
  end


end
