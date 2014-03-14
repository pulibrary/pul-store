require 'spec_helper'

describe PulStore::Lae::HardDrive do
  before(:all) do
    PulStore::Lae::HardDrive.delete_all
    PulStore::Lae::Box.delete_all
  end

  describe "project" do
    hd = FactoryGirl.create(:lae_hard_drive)
    hd.project.identifier.should == 'lae'
  end

  it "is Available when it does not have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    drive.workflow_state.should == "Available"
  end

  it "is in the same workflow_state as its box when it does have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    box = FactoryGirl.create(:lae_box_with_prelim_folders)
    drive.box = box
    drive.save!
    drive.workflow_state.should == box.workflow_state
  end

end
