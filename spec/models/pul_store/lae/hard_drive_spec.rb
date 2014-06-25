require 'spec_helper'

describe PulStore::Lae::HardDrive, :type => :model do
  before(:all) do
    PulStore::Lae::HardDrive.delete_all
    PulStore::Lae::Box.delete_all
  end

  after(:all) do
    PulStore::Lae::HardDrive.delete_all
    PulStore::Lae::Box.delete_all
  end

  it "should belong to the lae project" do
    hd = FactoryGirl.create(:lae_hard_drive)
    expect(hd.project.identifier).to eq('lae')
  end

  it "is Available when it does not have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    expect(drive.workflow_state).to eq("Available")
  end

  it "is in the same workflow_state as its box when it does have an associated Box" do
    drive = FactoryGirl.create(:lae_hard_drive)
    box = FactoryGirl.create(:lae_box_with_prelim_folders)
    drive.box = box
    drive.save!
    expect(drive.workflow_state).to eq(box.workflow_state)
  end

end
