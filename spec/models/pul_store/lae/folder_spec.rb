require 'spec_helper'

describe PulStore::Lae::Folder do
  before(:all) do
    @valid_barcode = "32101067661197"
    @invalid_barcode = "32101067661198"
    @short_barcode = "3210106770082"
    @bad_prefix_barcode = "2210106770082"
    FactoryGirl.create(:project)
  end

  it "has a valid factory" do
    FactoryGirl.create(:lae_folder).should be_valid
  end

  # describe "required elements" do
  #   required = [
  #     :barcode,
  #     :date_created, 
  #     :extent, 
  #     :rights, 
  #     :sort_title,
  #     :subject,
  #     :title
  #   ]
  #   required.each do |e|
  #     it "records are invaild if #{e} is missing" do
  #       f = FactoryGirl.build(:lae_folder, e => nil)
  #       f.valid?.should be_false
  #     end
  #   end
  # end

  describe "optional elements" do
    optional_elements = [
      :description,
      :series,
      :creator,
      :contributor,
      :publisher,
      :alternative_title
    ]
    optional_elements.each do |oe|
      it "#{oe} is not required" do
        f = FactoryGirl.build(:lae_folder, oe => nil)
        f.valid?.should be_true
      end

      it "#{oe} is empty by default" do
        f = FactoryGirl.build(:lae_folder, oe => nil)
        f.send(oe).blank?.should be_true
      end
    end
  end

  describe "repeatable elements" do
    optional_elements = [
      :alternative_title,
      :contributor,
      :creator,
      :geographic,
      :language,
      :publisher,
      :series,
      :subject
    ]
    optional_elements.each do |re|
      it "#{re} is repeatable" do
        v = []
        rand(1..4).times { v << Faker::Lorem.sentence }
        f = FactoryGirl.build(:lae_folder, re => v)
        f.save!
        f.reload
        f[re].should == v
      end
    end
  end

  describe "barcode validations" do

    it "is required" do
      f = FactoryGirl.build(:lae_folder, barcode: nil)
      f.valid?.should be_false
    end

    it "must be valid - try invalid" do
      expect {
        FactoryGirl.create(:lae_folder, barcode: @invalid_barcode)
      }.to raise_error ActiveFedora::RecordInvalid
    end

    it "must be valid - try valid" do
      expect {
        FactoryGirl.create(:lae_folder, barcode: @valid_barcode)
      }.not_to raise_error # ActiveFedora::RecordInvalid
    end

    it "must be 14 places long" do
      f = FactoryGirl.build(:lae_folder, barcode: @short_barcode)
      f.valid?.should be_false
    end

    it "start with 32101" do
      f = FactoryGirl.build(:lae_folder, barcode: @bad_prefix_barcode)
      f.valid?.should be_false
    end
  end

  describe "passed_qc" do

    describe "is false" do
      it "by default" do
        f = FactoryGirl.create(:lae_folder)
        f.passed_qc?.should be_false
      end
      it "passed_qc? responds as such when set" do
        f = FactoryGirl.create(:lae_folder)
        f.passed_qc = false
        f.save!
        f.passed_qc?.should be_false
      end
      it "passed_qc? responds as such by default" do
        f = FactoryGirl.create(:lae_folder)
        f.passed_qc?.should be_false
      end
    end

    describe "raises errors when setting to true" do
      it "without core elements" do
        f = FactoryGirl.build(:lae_folder)
        f.passed_qc = true
        expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
      end
      it "without pages" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.pages = []
        f.passed_qc = true
        expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
      end
    end

    it "can only be set to true when we have core elements and pages" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.passed_qc = true
      f.save!
      f.passed_qc?.should be_true
    end

  end

  describe "suppress" do
    it "is false by default" do
      f = FactoryGirl.create(:lae_folder)
      f.suppressed?.should be_false
    end

    it "responds to suppressed? as true when set" do
      f = FactoryGirl.build(:lae_folder)
      f.suppressed = true
      f.save!
      f.suppressed?.should be_true
    end

    it "responds to suppressed? as false when not set" do
      f = FactoryGirl.create(:lae_folder)
      f.suppressed = false
      f.save!
      f.suppressed?.should be_false
    end
  end


  describe "error note / error?" do
    it "error? responds with true when there is an error note" do
      f = FactoryGirl.build(:lae_folder)
      f.error_note = Faker::Lorem.paragraph
      f.save!
      f.error?.should be_true
    end
  end

  describe "has_prelim_metadata?" do
    it "responds with true when we have #{PulStore::Lae::Folder.prelim_elements}" do
      f = FactoryGirl.build(:lae_prelim_folder)
      f.extent = Faker::Lorem.sentence
      f.genre = Faker::Lorem.word
      f.has_prelim_metadata?.should be_true
    end

    describe "responds with false" do
      PulStore::Lae::Folder.prelim_elements.each do |pe|
        it "when #{pe} is missing" do
          f = FactoryGirl.build(:lae_prelim_folder)
          f[pe] = nil
          f.has_prelim_metadata?.should be_false
        end
      end
    end
  end


  describe "has_core_metadata?" do
    it "responds with true when we have #{PulStore::Lae::Folder.required_elements}" do
      f = FactoryGirl.build(:lae_core_folder)
      f.has_core_metadata?.should be_true
    end

    describe "responds with false" do
      PulStore::Lae::Folder.required_elements.each do |re|
        it "when #{re} is missing" do
          f = FactoryGirl.build(:lae_core_folder)
          f[re] = nil
          f.has_core_metadata?.should be_false
        end
      end
    end
  end

  describe "needs_qc?" do
    it "responds with true when we have our core elements, (valid) pages, and passed_qc is false" do
      f = FactoryGirl.build(:lae_core_folder)
      2.times do
        f.pages << FactoryGirl.create(:page)
      end
      f.save!
      f.needs_qc?.should be_true
    end

    describe "responds with false" do
      it "when there are no pages" do
        f = FactoryGirl.build(:lae_core_folder)
        f.needs_qc?.should be_false
      end

      it "when one of the pages is invalid" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.pages << FactoryGirl.build(:page, sort_order: nil)
        f.needs_qc?.should be_false
      end

    end
  end

  describe "in_production?" do
    it "responds with true when we qc_passed is true, there are no errors, and the suppressed is false" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.passed_qc = true
      f.in_production?.should be_true
    end

    describe "responds with false" do
      it "when passed_qc is false" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.passed_qc = false
        f.needs_qc?.should be_true
        f.in_production?.should be_false
      end

      it "there is an error note present" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.error_note = "HELP!"
        f.passed_qc = true
        f.needs_qc?.should be_false
        f.in_production?.should be_false
      end

      it "suppressed is true" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.passed_qc = true
        f.suppressed = true
        f.needs_qc?.should be_false
        f.in_production?.should be_false
      end
    end
  end


  describe "state" do
    it "is 'New' when we only have a barcode" do
      f = FactoryGirl.create(:lae_folder)
      f.state.should == "New"
    end

    it "is 'Has Prelim. Metadata' when we only have #{PulStore::Lae::Folder.prelim_elements}" do
      f = FactoryGirl.build(:lae_prelim_folder)
      f.save!
      f.state.should == 'Has Prelim. Metadata'
    end

    it "is 'Has Core Metadata' when we have #{PulStore::Lae::Folder.required_elements}" do
      f = FactoryGirl.build(:lae_core_folder)
      f.save!
      f.state.should == 'Has Core Metadata'
    end

    it "is 'Needs QC' when we have core metadata, we have valid pages, and qc_passed is false" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.save!
      f.state.should == 'Needs QC'
    end

    it "is 'In Production' when in_production? is true" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.passed_qc = true
      f.save!
      f.state.should == 'In Production'
    end

    # Error
    # Suppressed

  end


## THESE WILL NEED ADDITIONAL TESTS after we do QA impl.
# Genre
# Geographic
# Language
# Subject

# TOMORROW: 
# * Figure out what to do with lists (lang, genre, county, subject) (subject is extra complex)
# * hard_drive





end
