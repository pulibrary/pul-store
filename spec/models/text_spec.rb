require 'spec_helper'
require 'nokogiri'

describe Text do
  it 'has a valid factory' do
    FactoryGirl.create(:text).should be_valid
  end

  it 'can have many pages' do
    expected_page_count = rand(2..5)
    t = FactoryGirl.create(:text)
    expected_page_count.times do
      p = FactoryGirl.build(:page)
      p.text = t
      p.save
    end
    t.pages.length.should == expected_page_count
  end

  it 'gets a timestamp on save' do
    t = FactoryGirl.create(:text)
    t.date_modified.should_not be_nil

    u = FactoryGirl.build(:text)
    u.save
    u.date_modified.should_not be_nil
  end

  it 'has a date uploaded that does not change' do
    t = FactoryGirl.create(:text)
    d = t.date_uploaded
    t.title ="Changed title"
    t.save
    t.date_uploaded.should == d

  end

  it 'has a list of dates when it was modified' do
    t = FactoryGirl.create(:text)
    d = t.date_uploaded
    t.title ="Changed title"
    t.save
    t.date_modified.length.should == 2
  end

  it 'can get marcxml' do
    doc_id = '345682'
    mrx = Nokogiri::XML(Text.get_marcxml '345682')
    xp = '//marc:controlfield[@tag="001"][parent::marc:record[@type="Bibliographic"]]'
    id_from_mrx = mrx.xpath(xp)[0].content
    id_from_mrx.should == doc_id
  end

  it 'can save marcxml to its srcMetadata stream' do
    t = FactoryGirl.build(:text)
    t.dmd_system_id = '345682'
    t.src_metadata = Text.get_marcxml '345682'
    t.save

    t_from_repo = Text.find(t.pid)
    mrx = Nokogiri::XML(t_from_repo.src_metadata)
    xp = '//marc:controlfield[@tag="001"][parent::marc:record[@type="Bibliographic"]]'

    id_from_mrx = mrx.xpath(xp)[0].content
    id_from_mrx.should == t_from_repo.dmd_system_id
  end

  sample_marcxml_fp1 = File.join(RSpec.configuration.fixture_path, 'files', '4854502.mrx')
  sample_marcxml_fp2 = File.join(RSpec.configuration.fixture_path, 'files', '1160682.mrx')

  describe 'populate some descMetadata fields from MARC' do
    it 'can add alternative titles' do
      alt_tis = ["Fawāʼid al-fiqhīyah.", "الفوائد الفقهية"]
      Text.alternative_titles_from_marc(sample_marcxml_fp1).should == alt_tis
    end

    it 'doesn\'t choke when there are no alternative titles' do
      Text.alternative_titles_from_marc(sample_marcxml_fp2).should be_empty
    end

    it 'gets a language from the language table' do
    end

  end

end
