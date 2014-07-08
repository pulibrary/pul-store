require 'spec_helper'

describe PulStore::Page, :type => :model do

  # it_behaves_like "supports characterization"

  it "has a valid factory" do
    expect(FactoryGirl.create(:page)).to be_valid
  end

  it "gets a pid that is a NOID" do
    p = FactoryGirl.create(:page)
    expect(p.pid.start_with?(PUL_STORE_CONFIG['id_namespace'])).to be_truthy
  end

  it "has a sort_order" do
    expect(FactoryGirl.build(:page, sort_order: nil)).not_to be_valid
  end

  it "must belong to a parent" do
    expect(FactoryGirl.build(:page, text: nil)).not_to be_valid
  end

  it "can have a float as a sort_order" do
    expect(FactoryGirl.build(:page, sort_order: 4.1)).to be_valid
  end

  it "can take a master image" do
    p = FactoryGirl.build(:page)
    p.save
    expect(p.datastreams.keys.include?('masterImage')).to be_truthy
  end

  it "can populate its master_* fields from fits XML" do
    sample_fits_fp = File.join(RSpec.configuration.fixture_path, 'files', 'fits.xml')
    p = FactoryGirl.build(:page)
    p.master_tech_metadata = File.read(sample_fits_fp)
    expect(p.master_mime_type).to eq("image/tiff")
  end

  it "can characterize an image" do # TODO...no assertions here.
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    PulStore::Page.characterize(fp)
  end

  it "can make a jp2", unless: ENV['TRAVIS'] == 'true' do
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    p = FactoryGirl.build(:page)
    stage_path = PulStore::Page.upload_to_stage(File.new(fp), '0001.tif')
    p.master_image = stage_path
    p.save
    p.create_derivatives
    p.save
    expect(p.datastreams['deliverableImage']).to have_content
    expect(p.datastreams['deliverableImage'].mimeType).to eq('image/jp2')
  end

  it "deletes its jp2 from remote storage on #delete or #destroy", unless: ENV['TRAVIS'] == 'true' do
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    p = FactoryGirl.build(:page)
    stage_path = PulStore::Page.upload_to_stage(File.new(fp), '0001.tif')
    p.master_image = stage_path
    p.save
    p.create_derivatives
    p.save

    jp2_storage_root = PUL_STORE_CONFIG['image_server_store']
    local = PulStore::ImageServerUtils.pid_to_path(p.pid)
    path = "#{File.join(jp2_storage_root,local)}.jp2"

    PulStore::ImageServerUtils.stream_content_to_image_server(p.deliverableImage, p.pid)
    
    expect(File.exists?(path)).to be_truthy
    p.delete
    expect(File.exists?(path)).to be_falsey
  end

  describe "the pageOcr stream" do
    it "may be included" do
      ocr_fixture = RSpec.configuration.fixture_path + "/files/lae_test_img/32101075851483/32101075851434/0001.xml"
      p = FactoryGirl.build(:page)
      p.page_ocr = ocr_fixture
      p.save
      expect(p.datastreams.keys.include?('pageOcr')).to be_truthy
    end
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
        expect(p2.folder).to eq(f2)
        expect(f2.pages).to include(p2)
      end

      it "#text" do
        page = FactoryGirl.create(:page, text: @text, project: @project)
        expect(page.text).to eq(@text)
        t2 = PulStore::Text.find(@text.pid)
        p2 = PulStore::Page.find(page.pid)
        expect(p2.text).to eq(t2)
        expect(t2.pages).to include(p2)
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
