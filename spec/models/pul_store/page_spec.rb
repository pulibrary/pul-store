require 'spec_helper'

describe PulStore::Page do

  # it_behaves_like "supports characterization"

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

  it "must belong to a parent" do
    FactoryGirl.build(:page, text: nil).should_not be_valid
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

  it "can characterize an image" do # TODO...no assertions here.
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    PulStore::Page.characterize(fp)
  end

  describe "belongs to a parent" do
    before(:each) do
      PulStore::Page.delete_all
      PulStore::Lae::Box.delete_all
      PulStore::Lae::Folder.delete_all

      @project = PulStore::Project.first
      @box = FactoryGirl.create(:lae_box)
      @folder = FactoryGirl.create(:lae_core_folder, box: @box)
      @text = FactoryGirl.create(:text, project: @project)
    end

    describe "can make the association to either a PulStore::Lae::Folder or PulStore::Text" do
      it "#folder" do
        page = FactoryGirl.create(:page, folder: @folder, text: nil, project: @project)
        f2 = PulStore::Lae::Folder.find(@folder.pid)
        p2 = PulStore::Page.find(page.pid)
        p2.folder.should == f2
        f2.pages.should include(p2)
      end

      it "#text" do
        page = FactoryGirl.create(:page, text: @text, project: @project)
        page.text.should == @text
        t2 = PulStore::Text.find(@text.pid)
        p2 = PulStore::Page.find(page.pid)
        p2.text.should == t2
        t2.pages.should include(p2)
      end
    end

    describe "but only one" do
      it "#folder" do
        page = FactoryGirl.build(:page, folder: @folder, project: @project)
        page.text = @text
        expect { page.save! }.to raise_error ActiveFedora::RecordInvalid
      end

      it "#text" do
        page = FactoryGirl.build(:page, text: @text, project: @project)
        page.folder = @folder 
        expect { page.save! }.to raise_error ActiveFedora::RecordInvalid
      end
    end

  end


end
