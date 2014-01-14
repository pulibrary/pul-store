require 'spec_helper'

describe PulStore::Lae::Folder do
  before(:all) do
    @valid_barcode = "32101067700821"
    @invalid_barcode = "32101067700826"
    @short_barcode = "3210106770082"
    @bad_prefix_barcode = "2210106770082"
    FactoryGirl.create(:project)
  end

  it "has a valid factory" do
    FactoryGirl.create(:lae_folder).should be_valid
  end

  describe "barcode" do
    it "is required for saving" do
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

  describe "passed_qc" do
    it "is false by default" do
      f = FactoryGirl.create(:lae_folder)
      f.passed_qc?.should be_false
    end

    it "responds to passed_qc? as true when set" do
      f = FactoryGirl.build(:lae_folder)
      f.passed_qc = true
      f.save!
      f.passed_qc?.should be_true
    end

    it "responds to passed_qc? as false when not set" do
      f = FactoryGirl.create(:lae_folder)
      f.passed_qc = false
      f.save!
      f.passed_qc?.should be_false
    end
  end



end
