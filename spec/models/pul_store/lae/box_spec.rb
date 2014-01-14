require 'spec_helper'


describe PulStore::Lae::Box do
  before(:all) do
    @valid_barcode = "32101067700821"
    @invalid_barcode = "32101067700826"
    @short_barcode = "3210106770082"
    @bad_prefix_barcode = "2210106770082"
  end

  describe "barcode" do
    it "is required for saving" do
      b = PulStore::Lae::Box.new
      b.valid?.should be_false
    end

    it "must be valid - try invalid" do
      b = PulStore::Lae::Box.new(barcode: @invalid_barcode)
      expect { b.save! }.to raise_error ActiveFedora::RecordInvalid
    end

    it "must be valid - try valid" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      expect { b.save! }.not_to raise_error# ActiveFedora::RecordInvalid
    end

    it "must be 14 places long" do
      b = PulStore::Lae::Box.new(barcode: @short_barcode)
      b.valid?.should be_false
    end

    it "start with 32101" do
      b = PulStore::Lae::Box.new(barcode: @short_barcode)
      b.valid?.should be_false
    end
  end

  describe "full" do
    it "attr is false by default" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.save!
      b.full?.should be_false
    end

    it "responds to full? as true when set" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      b.save!
      b.full?.should be_true
    end

    it "responds to full? as false when not set" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = false
      b.save!
      b.full?.should be_false
    end

  end

  describe "shipment dates" do

    it "has shipped? that is true when the box is full there is a shipped_date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      b.shipped_date = DateTime.now.utc
      b.shipped?.should be_true
    end

    it "has shipped? that is false when there isn't a shipped_date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.shipped?.should be_false
    end

    it "has received? that is true when there is a received_date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      now = DateTime.now.utc
      b.shipped_date = now.ago 86400
      b.received_date = now
      b.received?.should be_true
    end

    it "has received? that is false when there isn't a received_date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      now = DateTime.now.utc
      b.shipped_date = now.ago 86400
      b.received?.should be_false
    end

    it "invalid if there is a received date when there is no shipped date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      b.received_date = DateTime.now.utc
      b.valid?.should be_false
    end

    it "invalid if the received date is before shipped date" do
    # validates_numericality_of :received_date,
    #   greater_than: :shipped_date, 
    #   message: "Received date must be after shipped date.",
    #   if: :received?
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.full = true
      now = DateTime.now.utc
      b.shipped_date = now
      b.received_date = now.ago 86400
      b.valid?.should be_false
    end

  end

  describe "tracking number" do

    it "is saveable" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      n = "no way to validate 123"
      b.shipped_date = DateTime.now.utc
      b.tracking_number = n
      b.save!
      b.reload
      b.tracking_number.should == n
    end

    it "causes the object to be invalid if present and there is not a ship date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.tracking_number = 'foo'
      b.valid?.should be_false
    end

    it "passes validation if there is also a ship date" do
      b = PulStore::Lae::Box.new(barcode: @valid_barcode)
      b.tracking_number = 'foo'
      b.shipped_date = DateTime.now.utc
      b.valid?.should be_true
    end

  end

end
