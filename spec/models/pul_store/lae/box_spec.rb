require 'spec_helper'

describe PulStore::Lae::Box do
  before(:all) do
    PulStore::Lae::Box.delete_all
    @invalid_barcode = "32101067700826"
    @short_barcode = "3210106770082"
    @bad_prefix_barcode = "2210106770082"
  end

  after(:all) do
    PulStore::Lae::Box.delete_all
  end

  describe "project" do
    b = FactoryGirl.create(:lae_box)
    b.project.identifier.should == 'lae'
  end

  describe "barcodes" do



    it "are required for saving" do
      b = PulStore::Lae::Box.new
      b.valid?.should be_false
    end

    it "are required for saving" do
      b = PulStore::Lae::Box.new
      b.valid?.should be_false
    end

    it "must be valid - try invalid" do
      b = FactoryGirl.build(:lae_box, barcode: @invalid_barcode)
      expect { b.save! }.to raise_error ActiveFedora::RecordInvalid
    end

    it "must be valid - try valid" do
      b = FactoryGirl.create(:lae_box)
      expect { b.save! }.not_to raise_error
    end

    it "must be 14 places long" do
      b = FactoryGirl.build(:lae_box, barcode: @short_barcode)
      b.valid?.should be_false
    end

    it "start with 32101" do
      b = FactoryGirl.build(:lae_box, barcode: @bad_prefix_barcode)
      b.valid?.should be_false
    end

    it "must be unique" do
      barcode = TEST_BARCODES.pop
      FactoryGirl.create(:lae_box, barcode: barcode)
      b = FactoryGirl.build(:lae_box, barcode: barcode)
      expect { b.save! }.to raise_error ActiveFedora::RecordInvalid
    end

    it "may not be updated with a duplicate barcode" do
      b = FactoryGirl.create(:lae_box)
      c = FactoryGirl.create(:lae_box)
      c.barcode = b.barcode
      expect { c.save! }.to raise_error ActiveFedora::RecordInvalid
    end

  end

  describe "full" do
    it "attr is false by default" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.save!
      b.full?.should be_false
    end

    it "responds to full? as true when set" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      b.save!
      b.full?.should be_true
    end

    it "responds to full? as false when not set" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = false
      b.save!
      b.full?.should be_false
    end

  end

  describe "physical location" do
    it "is added when we save" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.physical_location.should == PUL_STORE_CONFIG['lae_recap_code']
    end
  end

  describe "shipment dates" do

    it "shipped? is true when the box is full there is a shipped_date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      b.tracking_number = "12345"
      b.shipped_date = Date.current.to_s
      b.shipped?.should be_true
    end

    it "shipped? is false when there isn't a shipped_date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.shipped?.should be_false
    end

    it "received? is true when there is a received_date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      b.tracking_number = "12345"
      now = Date.current
      b.shipped_date = now.ago(86400).to_s
      b.received_date = now.to_s
      b.received?.should be_true
    end

    it "received? is false when there isn't a received_date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      b.tracking_number = "12345"
      b.shipped_date = Date.current.ago(86400).to_s
      b.received?.should be_false
    end

    it "Box is invalid if there is a received date when there is no shipped date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      b.received_date = Date.current.to_s
      b.valid?.should be_false
    end

    it "invalid if the received date is before shipped date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.full = true
      now = Date.current
      b.shipped_date = now.to_s
      b.received_date = now.ago(86400).to_s
      b.valid?.should be_false
    end

  end

  describe "tracking number" do

    it "is saveable" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      n = "no way to validate 123"
      b.shipped_date = Date.current
      b.tracking_number = n
      b.save!
      b.reload
      b.tracking_number.should == n
    end

    it "causes the object to be invalid if present and there is not a ship date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.tracking_number = 'foo'
      b.valid?.should be_false
    end

    it "passes validation if there is also a ship date" do
      b = FactoryGirl.create(:lae_box, barcode: TEST_BARCODES.pop)
      b.tracking_number = 'foo'
      b.shipped_date = Date.current.to_s
      b.valid?.should be_true
    end

  end

  describe "workflow_state" do

    it "is 'New' when we only have a barcode" do
      b = FactoryGirl.create(:lae_box)
      b.workflow_state.should == 'New'
    end

    it "is 'Ready to Ship' when all folders have prelim metadata" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.save!
      b.workflow_state.should == 'Ready to Ship'
    end

    it "is 'Shipped' when all folders have prelim metadata, we have a shipped date, and a tracking no" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.tracking_number = 'foo'
      b.shipped_date = Date.current
      b.save!
      b.workflow_state.should == 'Shipped'
    end


    it "is 'Received' when all folders have prelim metadata" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.tracking_number = 'foo'
      now = Date.current
      b.shipped_date = now.ago(604800).to_s
      b.received_date = now.to_s
      b.save!
      b.workflow_state.should == 'Received'
    end

    it "is 'All in Production' " do
      b = FactoryGirl.create(:lae_box_with_core_folders_with_pages)
      b.full = true
      b.tracking_number = 'foo'
      now = Date.current
      b.shipped_date = now.ago(604800).to_s
      b.received_date = now.to_s
      b.folders.each do |f|
        f.passed_qc = true
        f.save!
      end
      b.save!
      b.workflow_state.should == 'All in Production'
    end


  end

end
