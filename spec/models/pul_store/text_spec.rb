require 'spec_helper'
require 'nokogiri'

describe PulStore::Text do

  it 'has a valid factory' do
    FactoryGirl.create(:text).should be_valid
  end

  it "gets a pid that is a NOID" do
    t = FactoryGirl.create(:text)
    t.pid.start_with?(PUL_STORE_CONFIG['id_namespace']).should be_true
  end

  it 'can have many pages' do
    expected_page_count = rand(2..5)
    t = FactoryGirl.create(:text)
    expected_page_count.times do
      p = FactoryGirl.build(:page)
      p.text = t
      # t.pages << p
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
    mrx = Nokogiri::XML(PulStore::Text.get_marcxml '345682')
    xp = '//marc:controlfield[@tag="001"][parent::marc:record[@type="Bibliographic"]]'
    id_from_mrx = mrx.xpath(xp)[0].content
    id_from_mrx.should == doc_id
  end

  it 'can save marcxml to its srcMetadata stream' do
    t = FactoryGirl.build(:text)
    t.dmd_system_id = '345682'
    t.src_metadata = PulStore::Text.get_marcxml '345682'
    t.save

    t_from_repo = PulStore::Text.find(t.pid)
    mrx = Nokogiri::XML(t_from_repo.src_metadata)
    xp = '//marc:controlfield[@tag="001"][parent::marc:record[@type="Bibliographic"]]'

    id_from_mrx = mrx.xpath(xp)[0].content
    id_from_mrx.should == t_from_repo.dmd_system_id
  end

  sample_marcxml_fp1 = File.join(RSpec.configuration.fixture_path, 'files', '4854502.mrx')
  sample_marcxml_fp2 = File.join(RSpec.configuration.fixture_path, 'files', '1160682.mrx')
  sample_marcxml_fp3 = File.join(RSpec.configuration.fixture_path, 'files', '345682.mrx')
  sample_marcxml_fp4 = File.join(RSpec.configuration.fixture_path, 'files', '5325028.mrx')
  sample_marcxml_fp5 = File.join(RSpec.configuration.fixture_path, 'files', '6139836.mrx')
  sample_marcxml_fp6 = File.join(RSpec.configuration.fixture_path, 'files', '7910599.mrx')

  describe 'populate some descMetadata fields from MARC' do
    it 'can add alternative titles' do
      alt_tis = ["Fawāʼid al-fiqhīyah.", "الفوائد الفقهية"]
      PulStore::Text.alternative_titles_from_marc(sample_marcxml_fp1).should == alt_tis
    end

    it 'doesn\'t choke when there are no alternative titles' do
      PulStore::Text.alternative_titles_from_marc(sample_marcxml_fp2).should be_empty
    end

    it 'can get a hasPart from a 7xx with a ‡t' do
      c = ["Jones, Mary. Book by Mary."]
      PulStore::Text.has_parts_from_marc(sample_marcxml_fp3).should == c
    end

    it 'can get many hasParts from a many 7xxs with a ‡t' do
      c = ["Ghazzālī, 1058-1111. Durrah al-fākhirah fī kashf ʻulūm al-Ākhirah. Fragments.",
          "غزالي. درة الفاخرة في كشف علوم الاخرة",
          "Ghazzālī, 1058-1111. Kāfī fī al-ʻaqd al-ṣāfī. Fragments.",
          "غزالي. كافي في العقد الصافي",
          "Ghazzālī, 1058-1111. Qusṭās al-mustaqīm.",
          "غزالي. قسطاس المستقيم",
          "Ghazzālī, 1058-1111. ʻAqīdat ahl al-sunnah.",
          "غزالي. عقيدة اهل السنة",
          "Ghazzālī, 1058-1111. Iḥyāʾ ʻulūm al-dīn. Book 2, Faṣl 1.",
          "غزالي. احياء علوم الدين. كتاب 2، فصل 1",
          "Ghazzālī, 1058-1111. Iljām al-ʻawāmm ʻan ʻilm al-kalām.",
          "غزالي. الجام العوام عن علم الكلام",
          "Ghazzālī, 1058-1111. Munqidh min al-ḍalāl.",
          "غزالي. منقذ من الضلال",
          "Ghazzālī, 1058-1111. Jawāhir al-Qurʾān. Fragments.",
          "غزالي. جواهر القرآن",
          "Ghazzālī, 1058-1111. Mishkāt al-anwār.",
          "غزالي. مشكاة الانوار"
        ]
      PulStore::Text.has_parts_from_marc(sample_marcxml_fp4).should == c
    end

    it 'can get a toc' do
      c = "Contents / foo. ; Contents / bar -- Contents / baz"
      PulStore::Text.toc_from_marc(sample_marcxml_fp2).should == c
    end

    it 'is OK with no publisher' do
      PulStore::Text.publisher_from_marc(sample_marcxml_fp4).should be_empty
    end

    it 'can get a publisher' do
      PulStore::Text.publisher_from_marc(sample_marcxml_fp2).should == ['A. Martínez,']
    end

    it 'is OK with no extent' do
    end

    it 'can get extent' do
      e = ['i, 113, i leaves : paper ; 165 x 123 (140 x 100) mm. bound to 165 x 140 mm.']
      PulStore::Text.extent_from_marc(sample_marcxml_fp4).should == e
    end

    it 'can get abstract' do
      s = ["Collection of several treatises, some fragmentary or defective, by al-Ghazzālī."]
      PulStore::Text.abstract_from_marc(sample_marcxml_fp4).should == s
    end

    it 'can get languages crammed into one 041a' do
      l = ["German", "Italian"]
      PulStore::Text.language_from_marc(sample_marcxml_fp5).should == l
    end

    it 'can get languages from separate 041as' do
      l = ["Italian", "Spanish", "English", "French", "German"]
      PulStore::Text.language_from_marc(sample_marcxml_fp6).should == l
    end

    it 'can get a language from 008 35:37' do
      l = ['Arabic']
      PulStore::Text.language_from_marc(sample_marcxml_fp1).should == l
    end

  end

end
