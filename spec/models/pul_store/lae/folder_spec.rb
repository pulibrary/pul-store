require 'spec_helper'


describe PulStore::Lae::Folder do
  before(:all) do
    PulStore::Lae::Folder.delete_all
    @invalid_barcode = "32101067661198"
    @short_barcode = "3210106770082"
    @bad_prefix_barcode = "2210106770082"
  end

  after(:all) do
    PulStore::Lae::Folder.delete_all
  end

  it "has a valid factory" do
    FactoryGirl.create(:lae_folder).should be_valid
  end

  describe "project" do
    it "belonds to the lae project" do
      f = FactoryGirl.create(:lae_folder)
      f.project.identifier.should == 'lae'
    end
  end

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
    repeatable_elements = [
      :alternative_title,
      :contributor,
      :creator,
      :geographic_subject,
      :language,
      :publisher,
      :series,
      :subject
    ]
    repeatable_elements.each do |re|
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

  describe "barcodes" do

    it "are required" do
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
        FactoryGirl.create(:lae_folder)
      }.not_to raise_error # ActiveFedora::RecordInvalid
    end

    it "must be 14 places long" do
      f = FactoryGirl.build(:lae_folder, barcode: @short_barcode)
      f.valid?.should be_false
    end

    it "must start with 32101" do
      f = FactoryGirl.build(:lae_folder, barcode: @bad_prefix_barcode)
      f.valid?.should be_false
    end

    it "must be unique" do
      barcode = TEST_BARCODES.pop
      FactoryGirl.create(:lae_folder, barcode: barcode)
      b = FactoryGirl.build(:lae_folder, barcode: barcode)
      expect { b.save! }.to raise_error ActiveFedora::RecordInvalid
    end

    it "may not be updated with a duplicate barcode" do
      f = FactoryGirl.create(:lae_folder)
      g = FactoryGirl.create(:lae_folder)
      g.barcode = f.barcode
      expect { g.save! }.to raise_error ActiveFedora::RecordInvalid
    end
  end

  describe "physical_number" do
    it "must have a physical number" do
      f = FactoryGirl.build(:lae_folder, physical_number: nil)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
    end

    it "is valid with a physical number" do
      f = FactoryGirl.build(:lae_folder, physical_number: Faker::Number.digit.to_i+1)
      f.valid?.should be_true
    end

    it "it is invalid with a string value" do
      f = FactoryGirl.build(:lae_folder, physical_number: Faker::Lorem.word)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
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

  describe "has_extent?" do
    it "should be a valid model by default" do
      f = FactoryGirl.build(:lae_prelim_folder)
      f.should be_valid
    end

    it "should be false without any extent attributes" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      f.has_extent?.should be_false
    end

    it "should be true with a page count" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      f.page_count = 7
      f.has_extent?.should be_true
    end

    it "should be true with a width and height" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      f.width_in_cm = 5.5
      f.height_in_cm = 13
      f.has_extent?.should be_true
    end
  end

  describe "extent validation" do
    it "should not be valid without any extent attributes" do
      extent_params = { width_in_cm: nil, height_in_cm: nil, page_count: nil }
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
    end
    it "should not be valid without a height or page count" do
      extent_params = { width_in_cm: 7, height_in_cm: nil, page_count: nil }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
    end
    it "should not be valid without a width or page count" do
      extent_params = { width_in_cm: nil, height_in_cm: 4, page_count: nil }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
    end
    it "should only allow an integer for page count" do
      extent_params = { width_in_cm: nil, height_in_cm: nil, page_count: 'q' }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
    end
    describe "should only allow an integer or decimal for width and height" do
      it "integer" do
        extent_params = { width_in_cm: 1, height_in_cm: 1, page_count: nil }
        f = FactoryGirl.build(:lae_prelim_folder, extent_params)
        expect { f.save! }.not_to raise_error
      end
      it "decimal" do
        extent_params = { width_in_cm: 1.1, height_in_cm: 1.1, page_count: nil }
        f = FactoryGirl.build(:lae_prelim_folder, extent_params)
        expect { f.save! }.not_to raise_error
      end
    end
    it "should be valid with a page count" do
      extent_params = { width_in_cm: nil, height_in_cm: nil, page_count: 7 }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.not_to raise_error
    end
    it "should be an invalid model with a page count that is not nil or an integer" do
      extent_params = { width_in_cm: 50, height_in_cm: 50, page_count: "cats" }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      #expect { f.save! }.not_to raise_error #ActiveFedora::RecordInvalid
      f.should_not be_valid
    end
    it "should be an invalid model with a height/width that is not nil or an integer" do
      extent_params = { width_in_cm: 'fifty', height_in_cm: 'thirty', page_count: 25 }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      #expect { f.save! }.not_to raise_error #ActiveFedora::RecordInvalid
      f.should_not be_valid
    end
    it "should be valid with a width and height" do
      extent_params = { width_in_cm: 3.5, height_in_cm: 7, page_count: nil }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.not_to raise_error
    end
  end

  describe "has_prelim_metadata?" do
    it "responds with true when we have #{PulStore::Lae::Folder.prelim_elements} and page_count" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil)
      f.page_count = Faker::Number.digit
      f.genre = Faker::Lorem.word
      f.has_prelim_metadata?.should be_true
    end

    it "responds with true when we have #{PulStore::Lae::Folder.prelim_elements} and width and height" do
      f = FactoryGirl.build(:lae_prelim_folder, height_in_cm: nil)
      f.width_in_cm = Faker::Number.digit
      f.height_in_cm = Faker::Number.digit
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


  describe "workflow_state" do
    # it "is 'New' when we only have a barcode and genre" do
    #   f = FactoryGirl.create(:lae_folder, genre: 'xyz')
    #   f.workflow_state.should == "New"
    # end

    it "is 'Has Prelim. Metadata' when we only have #{PulStore::Lae::Folder.prelim_elements}" do
      f = FactoryGirl.build(:lae_prelim_folder)
      f.save!
      f.workflow_state.should == 'Has Prelim. Metadata'
    end

    it "is 'Has Core Metadata' when we have #{PulStore::Lae::Folder.required_elements}" do
      f = FactoryGirl.build(:lae_core_folder)
      f.save!
      f.workflow_state.should == 'Has Core Metadata'
    end

    it "is 'Needs QC' when we have core metadata, we have valid pages, and qc_passed is false" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.save!
      f.workflow_state.should == 'Needs QC'
    end

    it "is 'In Production' when in_production? is true" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.passed_qc = true
      f.save!
      f.workflow_state.should == 'In Production'
    end

    # Error
    # Suppressed

  end

  describe "rights statements" do

    it "has the default rights statement after creation" do
      barcode = TEST_BARCODES.pop
      f = FactoryGirl.build(:lae_folder, barcode: barcode)
      f.save!
      f.rights.should == PUL_STORE_CONFIG['lae_rights_boilerplate']
    end
  end


end
