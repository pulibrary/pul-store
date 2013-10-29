require 'spec_helper'

describe Page do
  it "has a valid factory" do
    FactoryGirl.create(:page).should be_valid
  end

  it "is not valid without a type" do
    FactoryGirl.build(:page, type: nil).should_not be_valid

    expect { 
      FactoryGirl.create(:page, type: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:page, type: 'NotAPage') 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:page, type: 'Page') 
    }.to_not raise_error
  end

  it "has a sort_order" do
    FactoryGirl.build(:page, sort_order: nil).should_not be_valid
  end

  it "can have a float as a sort_order" do
    FactoryGirl.build(:page, sort_order: 4.1).should be_valid
  end

  it "can take a master image" do
    p = FactoryGirl.build(:page)
    p.master_image = RSpec.configuration.fixture_path + "/files/00000001.tif"
    p.save
    p.datastreams.keys.include?('masterImage').should be_true
  end

  it_behaves_like "supports characterization"

end
