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
    sample_marcxml_fp4 = File.join(RSpec.configuration.fixture_path, 'files', '5325028.mrx')
    sample_marcxml_fp5 = File.join(RSpec.configuration.fixture_path, 'files', '7214786.mrx')

    it "can get a title" do
      ti = ["El desastre! Memorias de un voluntario en la campaña de Cuba."]
      Item.title_from_marc(sample_marcxml_fp1).should == ti

      ti = ["Opportunity in crisis : money and power in world politics 1986-88"]
      Item.title_from_marc(sample_marcxml_fp2).should == ti

      ti = ["Fawāʼid fiqhīyah", "فوائد فقهية"]
      Item.title_from_marc(sample_marcxml_fp3).should == ti
    end

    it "can get a sortable title" do
      sort_ti = "desastre! Memorias de un voluntario en la campaña de Cuba."
      Item.sort_title_from_marc(sample_marcxml_fp1).should == sort_ti

      sort_ti = "Opportunity in crisis : money and power in world politics 1986-88"
      Item.sort_title_from_marc(sample_marcxml_fp2).should == sort_ti

      sort_ti = "Fawāʼid fiqhīyah"
      Item.sort_title_from_marc(sample_marcxml_fp3).should == sort_ti
    end

    it "can get a creator or contributors" do
      cre = ["Corral, Manuel."]
      con = []
      Item.get_creator_from_marc(sample_marcxml_fp1).should == cre
      Item.get_contributors_from_marc(sample_marcxml_fp1).should == con

      cre = []
      con = ["White, Michael M.", "Smith, Bob F."]
      Item.get_creator_from_marc(sample_marcxml_fp2).should == cre
      Item.get_contributors_from_marc(sample_marcxml_fp2).should == con

      cre = ["Sharīshī, Muḥammad ibn Aḥmad, 1294?-1368?", "شريشي، محمد بن احمد"]
      con = []
      Item.get_creator_from_marc(sample_marcxml_fp3).should == cre
      Item.get_contributors_from_marc(sample_marcxml_fp3).should == con

      cre = []
      con = [
        "Ghazzālī, 1058-1111.",
        "غزالي",
        "Mawṣilī, Ḥusayn ibn al-Mubārak, d. 1341, copyist.", # we'll worry about this later... should probably use the marc relator properties
        "موصلي، حسين بن المبارك"
      ]
      Item.get_creator_from_marc(sample_marcxml_fp4).should == cre
      Item.get_contributors_from_marc(sample_marcxml_fp4).should == con
    end


    no260c_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'no_260c.mrx')
    no_date_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'no_date.mrx')
    bracket_century_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'bracket_century.mrx')
    unknown_annum_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'unknown_annum.mrx')
    unknown_decade_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'unknown_decade.mrx')
    
    it "can get a date from the 008" do
      Item.get_date_from_marc(no260c_marcxml).should == '1899'
    end

    it "can't get a date when there isn't one" do
      Item.get_date_from_marc(no_date_marcxml).should be nil
    end

    it "can get a date from e.g. '1899.'" do
      Item.get_date_from_marc(sample_marcxml_fp1).should == '1899'
    end

    it "can get a date from e.g. '[1305]'" do
      Item.get_date_from_marc(sample_marcxml_fp4).should == '1305'
    end

    it "can get a date from e.g. '[19]25'" do
      Item.get_date_from_marc(bracket_century_marcxml).should == '1925'
    end

    it "can get a date from e.g. '192x'" do
      Item.get_date_from_marc(unknown_annum_marcxml).should == '1920'
    end

    it "can get a gregorian date from e.g. '[772, i.e., 2012]'" do
      Item.get_date_from_marc(sample_marcxml_fp5).should == '2012'
    end

    it "can get a gregorian date from e.g. '[19--]'" do
      Item.get_date_from_marc(unknown_decade_marcxml).should == '1900'
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
