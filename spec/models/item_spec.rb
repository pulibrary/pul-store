require 'spec_helper'

describe Item do
  it "has a valid factory" do
    FactoryGirl.create(:item).should be_valid
  end

  it "is invalid without a title" do
    w = FactoryGirl.build(:item, title: nil)
    w.should_not be_valid

    expect { 
      FactoryGirl.create(:item, title: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:item, title: 'My Book') 
    }.to_not raise_error
  end

  it "is invalid without a sort title" do
    expect { 
      FactoryGirl.create(:item, sort_title: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:item, sort_title: 'My Book') 
    }.to_not raise_error
  end

  it "sorts by sort_title by default" do
    Item.delete_all
    ['cats', 'elephants', 'dogs'].each do |a|
       FactoryGirl.create(:item, sort_title: "All about #{a}") 
    end
    works = Item.all.sort
    if works[0].sort_title.is_a? Array 
      # should never be multiple, but is still a list; this is expected to change
      works[0].sort_title[0].should == "All about cats"
      works[1].sort_title[0].should == "All about dogs"
      works[2].sort_title[0].should == "All about elephants"
    else
      works[0].sort_title.should == "All about cats"
      works[1].sort_title.should == "All about dogs"
      works[2].sort_title.should == "All about elephants"
    end
  end

  describe "can get some of its descriptive metadata from MARCXML" do
    sample_marcxml_fp1 = File.join(RSpec.configuration.fixture_path, 'files', '1160682.mrx')
    sample_marcxml_fp2 = File.join(RSpec.configuration.fixture_path, 'files', '345682.mrx')
    sample_marcxml_fp3 = File.join(RSpec.configuration.fixture_path, 'files', '4854502.mrx')

    it "can get a title" do
      ti = ["El desastre! Memorias de un voluntario en la campaña de Cuba."]
      Item.title_from_marc(sample_marcxml_fp1).should == ti

      ti = ["Opportunity in crisis : money and power in world politics 1986-88"]
      Item.title_from_marc(sample_marcxml_fp2).should == ti

      ti = ["Fawāʼid fiqhīyah", "فوائد فقهية"]
      Item.title_from_marc(sample_marcxml_fp3).should == ti
    end

    it "can get a sortable title" do
      ti = "desastre! Memorias de un voluntario en la campaña de Cuba."
      Item.sort_title_from_marc(sample_marcxml_fp1).should == ti
    end

  end

  # it "may have zero or one creators"  do
  #   FactoryGirl.create(:item, creator: "Stroop, Jon").should be_valid
  # end

  # it "may not have more than one creator"  do
  #   expect { 
  #     FactoryGirl.create(:item, creator: ["Stroop, Jon", "Ellis, Shaun"])
  #   }.to raise_error ActiveFedora::RecordInvalid
  # end

  # it "may mave two or more contributors"  do
  #   cs = ["Stroop, Jon", "Ellis, Shaun"]
  #   cs << "Reiss, Kevin"
  #   FactoryGirl.create(:item, contributor: cs).should be_valid
  # end

  # it "must have zero creators if there are contributors" do
  #   cs = ["Stroop, Jon", "Ellis, Shaun"]
  #   expect { 
  #     FactoryGirl.create(:item, creator: "Reiss, Kevin", contributor: cs)
  #   }.to raise_error ActiveFedora::RecordInvalid
  # end 

  # it "has a date uploaded and date modified after it is saved" do
  #   w = Item.new(title:"The book", sort_title:"book", type: "Item")
  #   w.date_uploaded.should == []
  #   w.date_modified.should == []
  #   w.save!
  #   w.date_uploaded.should_not == [] # hmm....
  #   w.date_modified.should_not == [] # hmm....
  # end

  # it "has a identifier after it is saved ???"

  # it "gets a new a date modified after it is modified"
end
