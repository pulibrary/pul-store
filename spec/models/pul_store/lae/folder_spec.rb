require 'spec_helper'


describe PulStore::Lae::Folder, :type => :model do
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
    expect(FactoryGirl.create(:lae_folder)).to be_valid
  end

  describe "project" do
    it "belonds to the lae project" do
      f = FactoryGirl.create(:lae_folder)
      expect(f.project.identifier).to eq('lae')
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
        expect(f.valid?).to be_truthy
      end

      it "#{oe} is empty by default" do
        f = FactoryGirl.build(:lae_folder, oe => nil)
        expect(f.send(oe).blank?).to be_truthy
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
      :subject,
      :category
    ]
    repeatable_elements.each do |re|
      it "#{re} is repeatable" do
        v = []
        rand(1..4).times { v << Faker::Lorem.sentence }
        f = FactoryGirl.build(:lae_folder, re => v)
        f.save!
        f.reload
        expect(f[re]).to eq(v)
      end
    end
  end

  describe "barcodes" do

    it "are required" do
      f = FactoryGirl.build(:lae_folder, barcode: nil)
      expect(f.valid?).to be_falsey
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
      expect(f.valid?).to be_falsey
    end

    it "must start with 32101" do
      f = FactoryGirl.build(:lae_folder, barcode: @bad_prefix_barcode)
      expect(f.valid?).to be_falsey
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
      expect(f.valid?).to be_truthy
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
        expect(f.passed_qc?).to be_falsey
      end
      it "passed_qc? responds as such when set" do
        f = FactoryGirl.create(:lae_folder)
        f.passed_qc = false
        f.save!
        expect(f.passed_qc?).to be_falsey
      end
      it "passed_qc? responds as such by default" do
        f = FactoryGirl.create(:lae_folder)
        expect(f.passed_qc?).to be_falsey
      end
    end

    describe "raises errors when setting to true" do
      it 'does not let us set passed_qc to true if any arrays just contain an empty string ([""])' do
        f = FactoryGirl.create(:lae_core_folder_with_pages)
        f.subject = ['']
        f.passed_qc = true
        expect(f.valid?).to be_falsey
      end
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

    describe "may be set to true" do
      it "when we have core elements and pages" do
        f = FactoryGirl.create(:lae_core_folder_with_pages)
        f.passed_qc = true
        f.save!
        expect(f.passed_qc?).to be_truthy
      end
    end

  end

  describe "suppress" do
    it "is false by default" do
      f = FactoryGirl.create(:lae_folder)
      expect(f.suppressed?).to be_falsey
    end

    it "responds to suppressed? as true when set" do
      f = FactoryGirl.build(:lae_folder)
      f.suppressed = true
      f.save!
      expect(f.suppressed?).to be_truthy
    end

    it "responds to suppressed? as false when not set" do
      f = FactoryGirl.create(:lae_folder)
      f.suppressed = false
      f.save!
      expect(f.suppressed?).to be_falsey
    end
  end


  describe "error note / error?" do
    it "error? responds with true when there is an error note" do
      f = FactoryGirl.build(:lae_folder)
      f.error_note = Faker::Lorem.paragraph
      f.save!
      expect(f.error?).to be_truthy
    end
  end

  describe "has_extent?" do
    it "should be a valid model by default" do
      f = FactoryGirl.build(:lae_prelim_folder)
      expect(f).to be_valid
    end

    it "should be false without any extent attributes" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      expect(f.has_extent?).to be_falsey
    end

    it "should be true with a page count" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      f.page_count = 7
      expect(f.has_extent?).to be_truthy
    end

    it "should be true with a width and height" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil, page_count: nil)
      f.width_in_cm = 5.5
      f.height_in_cm = 13
      expect(f.has_extent?).to be_truthy
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
      # it "decimal" do
      #   extent_params = { width_in_cm: 1.1, height_in_cm: 1.1, page_count: nil }
      #   f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      #   expect { f.save! }.not_to raise_error
      # end
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
      expect(f).not_to be_valid
    end
    it "should be an invalid model with a height/width that is not nil or an integer" do
      extent_params = { width_in_cm: 'fifty', height_in_cm: 'thirty', page_count: 25 }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      #expect { f.save! }.not_to raise_error #ActiveFedora::RecordInvalid
      expect(f).not_to be_valid
    end
    it "should be valid with a width and height" do
      extent_params = { width_in_cm: 3, height_in_cm: 7, page_count: nil }
      f = FactoryGirl.build(:lae_prelim_folder, extent_params)
      expect { f.save! }.not_to raise_error
    end
  end

  describe "date field requirements to pass qc" do
    f = FactoryGirl.create(:lae_core_folder_with_pages)
    f.passed_qc = true

    describe "one approach is required" do
      it "all can't be nil" do
        f.date_created = nil
        f.earliest_created = nil
        f.latest_created = nil
        expect(f.valid?).to be_falsey
      end

      it "all can't be ''" do
        f.date_created = ''
        f.earliest_created = ''
        f.latest_created = ''
        expect(f.valid?).to be_falsey
      end

      it "OK if it has a (valid) date_created" do
        f.date_created = 1999
        f.earliest_created = nil
        f.latest_created = nil
        expect(f.valid?).to be_truthy
      end

      it "OK if it has a (valid) earliest_created and latest_created" do
        f.date_created = nil
        f.earliest_created = 1999
        f.latest_created = 2001
        expect(f.valid?).to be_truthy
      end

      it "but both earliest_created and latest_created are required" do
        f.date_created = nil
        f.earliest_created = 1999
        f.latest_created = nil
        expect(f.valid?).to be_falsey
      end
    end

    describe "values" do
      it "earlier must be less than later" do
        f.date_created = nil
        f.earliest_created = 1999
        f.latest_created = 1997
        expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
      end

      it "may not have both a range and a single date" do
        f.date_created = 1998
        f.earliest_created = 1997
        f.latest_created = 1999
        expect { f.save! }.to raise_error ActiveFedora::RecordInvalid
      end

      describe "must be a 19xx or 20xx year" do
        it "date_created" do
          f.date_created = "199?"
          f.earliest_created = nil
          f.latest_created = nil
          expect(f.valid?).to be_falsey
        end

        it "earliest_created" do
          f.date_created = nil
          f.earliest_created = 3005
          f.latest_created = 2007
          expect(f.valid?).to be_falsey
        end

        it "latest_created" do
          f.date_created = nil
          f.earliest_created = 1999
          f.latest_created = "200?"
          #f.valid?.should be_false
          expect { f.valid? }.to raise_error ArgumentError
        end
      end
    end

    # TODO: format, and earlier < later
    # TODO: format regex

  end


  describe "has_prelim_metadata?" do
    it "responds with true when we have #{PulStore::Lae::Folder.prelim_elements} and page_count" do
      f = FactoryGirl.build(:lae_prelim_folder, width_in_cm: nil, height_in_cm: nil)
      f.page_count = Faker::Number.digit
      f.genre = Faker::Lorem.word
      expect(f.has_prelim_metadata?).to be_truthy
    end

    it "responds with false if one of the repeatable elements is all empty strings" do
      data =  ['','']
      f = FactoryGirl.build(:lae_core_folder, genre: data)
      expect(f.has_prelim_metadata?).to be_falsey
    end

    it "responds with true when we have #{PulStore::Lae::Folder.prelim_elements} and width and height" do
      f = FactoryGirl.build(:lae_prelim_folder, height_in_cm: nil)
      f.width_in_cm = Faker::Number.digit
      f.height_in_cm = Faker::Number.digit
      f.genre = Faker::Lorem.word
      expect(f.has_prelim_metadata?).to be_truthy
    end

    describe "responds with false" do
      PulStore::Lae::Folder.prelim_elements.each do |pe|
        it "when #{pe} is missing" do
          f = FactoryGirl.build(:lae_prelim_folder)
          f[pe] = nil
          expect(f.has_prelim_metadata?).to be_falsey
        end
      end
    end
  end


  describe "has_core_metadata?" do
    it "responds with true when we have #{PulStore::Lae::Folder.required_elements}" do
      f = FactoryGirl.build(:lae_core_folder)
      expect(f.has_core_metadata?).to be_truthy
    end

    it "responds with false if one of the repeatable elements is all empty strings" do
      data =  ['','']
      f = FactoryGirl.build(:lae_core_folder, category: data)
      expect(f.has_core_metadata?).to be_falsey
    end

    it "earliest_created and latest_created may be swapped for date_created" do
      f = FactoryGirl.build(:lae_core_folder, date_created: nil, earliest_created: 1999, latest_created: 2002)
      expect(f.has_core_metadata?).to be_truthy
    end

    it "width_in_cm and height_in_cm may be swapped for page_count" do
      f = FactoryGirl.build(:lae_core_folder, width_in_cm: 5, height_in_cm: 7, page_count: nil)
      expect(f.has_core_metadata?).to be_truthy
    end

    describe "responds with false" do
      PulStore::Lae::Folder.required_elements.each do |re|
        it "when #{re} is missing" do
          f = FactoryGirl.build(:lae_core_folder)
          f[re] = nil
          expect(f.has_core_metadata?).to be_falsey
        end
      end
    end
  end

  describe "needs_qc?" do
    it "responds with true when we have our core elements, (valid) pages, and passed_qc is false" do
      f = FactoryGirl.build(:lae_core_folder)
      f.pages << FactoryGirl.create(:page)
      expect(f.needs_qc?).to be_truthy
    end

    describe "responds with false" do
      it "when there are no pages" do
        f = FactoryGirl.build(:lae_core_folder)
        expect(f.needs_qc?).to be_falsey
      end

      it "when one of the pages is invalid" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.pages << FactoryGirl.build(:page, sort_order: nil)
        expect(f.needs_qc?).to be_falsey
      end

    end
  end

  describe "in_production?" do
    it "responds with true when we qc_passed is true, there are no errors, and the suppressed is false" do
      f = FactoryGirl.build(:lae_core_folder_with_pages)
      f.passed_qc = true
      expect(f.in_production?).to be_truthy
    end

    describe "responds with false" do
      it "when passed_qc is false" do
        f = FactoryGirl.create(:lae_core_folder_with_pages)
        expect(f.needs_qc?).to be_truthy
        expect(f.in_production?).to be_falsey
      end

      it "there is an error note present" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.error_note = "HELP!"
        f.passed_qc = true
        expect(f.needs_qc?).to be_falsey
        expect(f.in_production?).to be_falsey
      end

      it "suppressed is true" do
        f = FactoryGirl.build(:lae_core_folder_with_pages)
        f.passed_qc = true
        f.suppressed = true
        expect(f.needs_qc?).to be_falsey
        expect(f.in_production?).to be_falsey
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
      expect(f.workflow_state).to eq('Has Prelim. Metadata')
    end

    it "is 'Has Core Metadata' when we have #{PulStore::Lae::Folder.required_elements}" do
      f = FactoryGirl.build(:lae_core_folder)
      f.save!
      expect(f.workflow_state).to eq('Has Core Metadata')
    end

    it "is 'Needs QC' when we have core metadata, we have valid pages, and qc_passed is false" do
      f = FactoryGirl.create(:lae_core_folder_with_pages)
      f.save!
      expect(f.workflow_state).to eq('Needs QC')
    end

    it "is 'In Production' when in_production? is true" do
      f = FactoryGirl.create(:lae_core_folder_with_pages)
      f.passed_qc = true
      f.save!
      expect(f.workflow_state).to eq('In Production')
    end

    # Error
    # Suppressed

  end

  describe "rights statements" do

    it "has the default rights statement after creation" do
      barcode = TEST_BARCODES.pop
      f = FactoryGirl.build(:lae_folder, barcode: barcode)
      f.save!
      expect(f.rights).to eq(PUL_STORE_CONFIG['lae_rights_boilerplate'])
    end
  end

  describe 'export features' do

    describe '#to_export' do
      box  = FactoryGirl.create(:lae_box)
      let(:folder) { FactoryGirl.create(:lae_core_folder_with_pages, box: box) }

      it "returns nil when the workflow_state is not 'In Production'" do
        folder.passed_qc = false
        folder.save!
        expect(folder.to_export).to eq nil
      end

      it "returns a hash nil when the workflow_state is 'In Production'" do
        folder.passed_qc = true
        folder.save!
        expect(folder.to_export).to be_a Hash
      end
    end

    describe "#to_yaml" do
      box  = FactoryGirl.create(:lae_box)
      let(:folder) { FactoryGirl.create(:lae_core_folder_with_pages, box: box) }

      it "produces parsable YAML" do
        folder.passed_qc = true
        folder.save!
        expect { YAML.load(folder.to_yaml) }.not_to raise_error
      end

      it "excludes the keys we done want (from config/pul_store.yml)" do
        folder.passed_qc = true
        folder.save!
        h = YAML.load(folder.to_yaml)
        expect(h.has_key?('object_profile_ssm')).to be_falsey
      end
    end

  end

end


