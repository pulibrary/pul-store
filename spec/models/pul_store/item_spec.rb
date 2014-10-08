require 'spec_helper'

describe PulStore::Item, :type => :model do

  before(:all) do
     # We need to make sure there's at least one Project in the repo so that 
     # PulStore::Item and it's subclasses have something to use
    FactoryGirl.create(:project)
  end

  it "has a valid factory" do
    expect(FactoryGirl.create(:item)).to be_valid
  end

  it "gets a pid that is a NOID" do
    i = FactoryGirl.create(:item)
    expect(i.pid.start_with?(PUL_STORE_CONFIG['id_namespace'])).to be_truthy
  end

  it "is invalid without a title" do
    w = FactoryGirl.build(:item, title: nil)
    expect(w).not_to be_valid

    expect { 
      FactoryGirl.create(:item, title: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:item, title: ['My Book']) 
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
    PulStore::Item.delete_all
    ['cats', 'elephants', 'dogs'].each do |a|
       FactoryGirl.create(:item, sort_title: "All about #{a}") 
    end
    works = PulStore::Item.all.sort
    if works[0].sort_title.is_a? Array 
      # should never be multiple, but is still a list; this is expected to change
      expect(works[0].sort_title[0]).to eq("All about cats")
      expect(works[1].sort_title[0]).to eq("All about dogs")
      expect(works[2].sort_title[0]).to eq("All about elephants")
    else
      expect(works[0].sort_title).to eq("All about cats")
      expect(works[1].sort_title).to eq("All about dogs")
      expect(works[2].sort_title).to eq("All about elephants")
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
      expect(PulStore::Item.title_from_marc(sample_marcxml_fp1)).to eq(ti)

      ti = ["Opportunity in crisis : money and power in world politics 1986-88"]
      expect(PulStore::Item.title_from_marc(sample_marcxml_fp2)).to eq(ti)

      ti = ["Fawāʼid fiqhīyah", "فوائد فقهية"]
      expect(PulStore::Item.title_from_marc(sample_marcxml_fp3)).to eq(ti)
    end

    it "can get a sortable title" do
      sort_ti = "desastre! Memorias de un voluntario en la campaña de Cuba."
      expect(PulStore::Item.sort_title_from_marc(sample_marcxml_fp1)).to eq(sort_ti)

      sort_ti = "Opportunity in crisis : money and power in world politics 1986-88"
      expect(PulStore::Item.sort_title_from_marc(sample_marcxml_fp2)).to eq(sort_ti)

      sort_ti = "Fawāʼid fiqhīyah"
      expect(PulStore::Item.sort_title_from_marc(sample_marcxml_fp3)).to eq(sort_ti)
    end

    it "can get a creator or contributors" do
      cre = ["Corral, Manuel."]
      con = []
      expect(PulStore::Item.creator_from_marc(sample_marcxml_fp1)).to eq(cre)
      expect(PulStore::Item.contributors_from_marc(sample_marcxml_fp1)).to eq(con)

      cre = []
      con = ["White, Michael M.", "Smith, Bob F."]
      expect(PulStore::Item.creator_from_marc(sample_marcxml_fp2)).to eq(cre)
      expect(PulStore::Item.contributors_from_marc(sample_marcxml_fp2)).to eq(con)

      cre = ["Sharīshī, Muḥammad ibn Aḥmad, 1294?-1368?", "شريشي، محمد بن احمد"]
      con = []
      expect(PulStore::Item.creator_from_marc(sample_marcxml_fp3)).to eq(cre)
      expect(PulStore::Item.contributors_from_marc(sample_marcxml_fp3)).to eq(con)

      cre = []
      con = [
        "Ghazzālī, 1058-1111.",
        "غزالي",
        "Mawṣilī, Ḥusayn ibn al-Mubārak, d. 1341, copyist.", # we'll worry about this later... should probably use the marc relator properties
        "موصلي، حسين بن المبارك"
      ]
      expect(PulStore::Item.creator_from_marc(sample_marcxml_fp4)).to eq(cre)
      expect(PulStore::Item.contributors_from_marc(sample_marcxml_fp4)).to eq(con)
    end


    no260c_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'no_260c.mrx')
    no_date_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'no_date.mrx')
    bracket_century_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'bracket_century.mrx')
    unknown_annum_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'unknown_annum.mrx')
    unknown_decade_marcxml = File.join(RSpec.configuration.fixture_path, 'files', 'unknown_decade.mrx')
    
    it "can get a date from the 008" do
      expect(PulStore::Item.date_from_marc(no260c_marcxml)).to eq('1899')
    end

    it "can't get a date when there isn't one" do
      expect(PulStore::Item.date_from_marc(no_date_marcxml)).to be nil
    end

    it "can get a date from e.g. '1899.'" do
      expect(PulStore::Item.date_from_marc(sample_marcxml_fp1)).to eq('1899')
    end

    it "can get a date from e.g. '[1305]'" do
      expect(PulStore::Item.date_from_marc(sample_marcxml_fp4)).to eq('1305')
    end

    it "can get a date from e.g. '[1345?]'" do
      expect(PulStore::Item.date_from_marc(sample_marcxml_fp3)).to eq('1345')
    end


    it "can get a date from e.g. '[19]25'" do
      expect(PulStore::Item.date_from_marc(bracket_century_marcxml)).to eq('1925')
    end

    it "can get a date from e.g. '192x'" do
      expect(PulStore::Item.date_from_marc(unknown_annum_marcxml)).to eq('1920')
    end

    it "can get a gregorian date from e.g. '[772, i.e., 2012]'" do
      expect(PulStore::Item.date_from_marc(sample_marcxml_fp5)).to eq('2012')
    end

    it "can get a gregorian date from e.g. '[19--]'" do
      expect(PulStore::Item.date_from_marc(unknown_decade_marcxml)).to eq('1900')
    end
    
  end
 
end
