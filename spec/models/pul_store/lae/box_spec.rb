require 'spec_helper'

describe PulStore::Lae::Box, :type => :model do
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
    it "should belong to the lae project" do
      b = FactoryGirl.create(:lae_box)
      expect(b.project.identifier).to eq('lae')
    end
  end

  describe "physical_number" do

    it "should not be assigned if the box is invalid" do
      bad_box = FactoryGirl.build(:lae_box, barcode: @invalid_barcode)
      expect { bad_box.save! }.to raise_error ActiveFedora::RecordInvalid
      expect(bad_box.physical_number).to be_nil
    end

    it "should be an auto-assigned number" do
      b = FactoryGirl.create(:lae_box)
      #b.physical_number.should match(/^(\d+)$/)
      expect(b.physical_number.is_a?(Fixnum)).to be_truthy
      expect(b.physical_number).not_to be_blank
    end
  end

  describe "barcodes" do

    it "are required for saving" do
      b = PulStore::Lae::Box.new
      expect(b.valid?).to be_falsey
    end

    it "are required for saving" do
      b = PulStore::Lae::Box.new
      expect(b.valid?).to be_falsey
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
      expect(b.valid?).to be_falsey
    end

    it "start with 32101" do
      b = FactoryGirl.build(:lae_box, barcode: @bad_prefix_barcode)
      expect(b.valid?).to be_falsey
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
      b = FactoryGirl.create(:lae_box)
      b.save!
      expect(b.full?).to be_falsey
    end

    it "responds to full? as true when set" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      b.save!
      expect(b.full?).to be_truthy
    end

    it "responds to full? as false when not set" do
      b = FactoryGirl.create(:lae_box)
      b.full = false
      b.save!
      expect(b.full?).to be_falsey
    end

  end

  describe "physical location" do
    it "is added when we save" do
      b = FactoryGirl.create(:lae_box)
      expect(b.physical_location).to eq(PUL_STORE_CONFIG['lae_recap_code'])
    end
  end

  describe "shipment dates" do

    it "shipped? is true when the box is full there is a shipped_date" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      b.tracking_number = "12345"
      b.shipped_date = Date.current.to_s
      expect(b.shipped?).to be_truthy
    end

    it "shipped? is false when there isn't a shipped_date" do
      b = FactoryGirl.create(:lae_box)
      expect(b.shipped?).to be_falsey
    end

    it "received? is true when there is a received_date" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      b.tracking_number = "12345"
      now = Date.current
      b.shipped_date = now.ago(86400).to_s
      b.received_date = now.to_s
      expect(b.received?).to be_truthy
    end

    it "received? is false when there isn't a received_date" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      b.tracking_number = "12345"
      b.shipped_date = Date.current.ago(86400).to_s
      expect(b.received?).to be_falsey
    end

    it "Box is invalid if there is a received date when there is no shipped date" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      b.received_date = Date.current.to_s
      expect(b.valid?).to be_falsey
    end

    it "invalid if the received date is before shipped date" do
      b = FactoryGirl.create(:lae_box)
      b.full = true
      now = Date.current
      b.shipped_date = now.to_s
      b.received_date = now.ago(86400).to_s
      expect(b.valid?).to be_falsey
    end

  end

  describe "tracking number" do

    it "is saveable" do
      b = FactoryGirl.create(:lae_box)
      n = 123456
      b.shipped_date = Date.current
      b.tracking_number = n
      b.save!
      b.reload
      expect(b.tracking_number).to eq(n)
    end

    it "causes the object to be invalid if present and there is not a ship date" do
      b = FactoryGirl.create(:lae_box)
      b.tracking_number = 'foo'
      expect(b.valid?).to be_falsey
    end

    it "passes validation if there is also a ship date" do
      b = FactoryGirl.create(:lae_box)
      b.tracking_number = 'foo'
      b.shipped_date = Date.current.to_s
      expect(b.valid?).to be_truthy
    end

  end

  describe "workflow_state" do

    it "is 'New' when we only have a barcode" do
      b = FactoryGirl.create(:lae_box)
      expect(b.workflow_state).to eq('New')
    end

    it "is 'Ready to Ship' when all folders have prelim metadata" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.save!
      expect(b.workflow_state).to eq('Ready to Ship')
    end

    it "is 'Shipped' when all folders have prelim metadata, we have a shipped date, and a tracking no" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.tracking_number = 'foo'
      b.shipped_date = Date.current
      b.save!
      expect(b.workflow_state).to eq('Shipped')
    end


    it "is 'Received' when all folders have prelim metadata" do
      b = FactoryGirl.create(:lae_box_with_prelim_folders)
      b.full = true
      b.tracking_number = 'foo'
      now = Date.current
      b.shipped_date = now.ago(604800).to_s
      b.received_date = now.to_s
      b.save!
      expect(b.workflow_state).to eq('Received')
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
      expect(b.workflow_state).to eq('All in Production')
    end


  end

  describe "can_be_shared" do
    it "Can Share Folder Data" do
      b = FactoryGirl.create(:lae_box_with_core_folders_with_pages_not_shared)
      b.shareable = "true"
      b.save!
      expect(b.shareable?).to be_truthy
    end

    it "Allows the public to read" do
      b = FactoryGirl.create(:lae_box_with_core_folders_with_pages_not_shared)
      b.shareable = "true"
      b.save!
      expect(b.read_groups).to include('public')
    end

    it "Cannot Share Folder Data" do
      b = FactoryGirl.create(:lae_box_with_core_folders_with_pages_not_shared)
      b.save!
      expect(b.shareable?).to be_falsey
    end
  end

end
