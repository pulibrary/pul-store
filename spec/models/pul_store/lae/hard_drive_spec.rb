require 'spec_helper'

describe PulStore::Lae::HardDrive do
  before(:all) do
    PulStore::Lae::HardDrive.delete_all
    PulStore::Lae::Box.delete_all
  end

  it "is Available when it does not have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    drive.state.should == "Available"
  end

  it "is in the same state as its box when it does have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    box = FactoryGirl.create(:lae_box_with_prelim_folders)
    drive.box = box
    drive.save!
    drive.state.should == box.state
  end

end
