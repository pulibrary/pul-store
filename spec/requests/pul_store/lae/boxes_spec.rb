require 'spec_helper'

describe "Lae::BoxesController", :type => :request do

  subject { 
    box = FactoryGirl.create(:lae_box)
    FactoryGirl.create(:lae_core_folder_with_pages, box: box)
    box
  }

  before(:each) do
    User.delete_all
    PulStore::Lae::Box.delete_all
    @user = FactoryGirl.create(:user)
    @user.save!
  end


  describe "GET /lae/boxes" do
    it "works!" do
      login_as(@user, :scope => :user)
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get lae_boxes_path
      expect(response.status).to be(200)
    end

  end

  describe "GET /lae/boxes.xml" do
    it 'gets a box as xml' do
      login_as(@user, scope: :user)
      get lae_box_path(subject), {format: :xml, all: 'xyz'}
      expect(response.status).to be(200)
    end
    it 'looks like Solr XML' do
      login_as(@user, scope: :user)
      get lae_box_path(subject), {format: :xml, all: 'xyz'}
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

end
