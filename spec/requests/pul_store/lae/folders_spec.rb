require 'spec_helper'
require 'rdf/turtle'
require 'nokogiri'
include Warden::Test::Helpers

describe "Lae::FoldersController", type: :request do

  let(:box) { FactoryGirl.create(:lae_box) }
  let(:folder) { FactoryGirl.create(:lae_core_folder_with_pages, box: box) }

  before(:all) do
    PulStore::Lae::Folder.delete_all
    PulStore::Lae::Box.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end

  describe "GET /lae/folders" do
    it "works!" do
      login_as(@user, :scope => :user)
      get lae_folders_path
      expect(response.status).to be(200)
    end
  end

  describe "GET /lae/folders/{folder}.ttl" do
    it 'gets a folder as turtle' do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :ttl, all: 'xyz'}
      expect(response.status).to be(200)
    end
    it 'returns a 406 is the object isn\'t baked and ?all is not passed'  do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :ttl}
      expect(response.status).to be(406)
    end
    it 'the turtle is parsable' do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :ttl, all: 'xyz'}
      expect { 
        RDF::Reader.for(:turtle).new(response.body) do |reader|
          reader.each_statement { |s| s.inspect }
        end
      }.to_not raise_error
    end
  end

  describe "GET /lae/folders/{folder}.xml" do
    it 'gets a folder as xml' do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :xml, all: 'xyz'}
      expect(response.status).to be(200)
    end
    it 'returns a 406 is the object isn\'t baked and ?all is not passed'  do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :xml}
      expect(response.status).to be(406)
    end
    it 'looks like Solr XML' do
      login_as(@user, scope: :user)
      get lae_folder_path(folder), {format: :xml, all: 'xyz'}
      doc = Nokogiri::XML(response.body)
      expect(doc.xpath('/*').first.name).to eq 'add'
      expect(doc.xpath('/add/*').all? { |e| 
        e.name == 'doc'
      }).to be_truthy
      expect(doc.xpath('/add/doc/*').all? { |e| 
        e.name == 'field'
      }).to be_truthy
      expect(doc.xpath('/add/doc/*').all? { |field| 
        field.attributes.length == 1 
      }).to be_truthy
      expect(doc.xpath('/add/doc/*').all? { |field| 
        field.attributes.first[0] == 'name' 
      }).to be_truthy
    end
  end

  describe "POST /lae/folders" do
    it "Should create a new folder with valid attributes" do
      login_as(@user, :scope => :user)
      params = FactoryGirl.attributes_for(:lae_prelim_folder)
      post lae_folders_path, { lae_folder: params}
      expect(response.status).to be(302)
    end

    it "Should create a new folder with valid attributes and be able to respond w/ JSON" do
      login_as(@user, :scope => :user)
      params = FactoryGirl.attributes_for(:lae_prelim_folder)
      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      expect(response.status).to be(201)
      expect(JSON.parse(response.body)['barcode']).to eq(params[:barcode].to_s)
    end

    it "Should not allow us to make dupes (validations should be enforced" do
      login_as(@user, :scope => :user)
      params = FactoryGirl.attributes_for(:lae_prelim_folder)

      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      expect(response.status).to be(201)
      expect(JSON.parse(response.body)['barcode']).to eq(params[:barcode].to_s)

      post lae_folders_path, { lae_folder: params }, { 'Accept' => 'application/json' }
      expect(JSON.parse(response.body)['barcode']).not_to be_nil
    end
  end

end
