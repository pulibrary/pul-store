require 'spec_helper'

describe Page do

  it_behaves_like "supports characterization"

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
    p.save
    p.datastreams.keys.include?('masterImage').should be_true
  end

  it "can populate its master_* fields from fits XML" do
    sample_fits_fp = File.join(RSpec.configuration.fixture_path, 'files', 'fits.xml')
    p = FactoryGirl.build(:page)
    p.master_tech_md = File.read(sample_fits_fp)
    p.master_mime_type.should == "image/tiff"
  end

end
