require 'spec_helper'

describe PulStore::Project do
  it "has a valid factory" do
    FactoryGirl.create(:project).should be_valid
  end

  it "can not be deleted if it has associated children" do
    p = FactoryGirl.create(:project)
    i = FactoryGirl.create(:item)
    p.parts << i
    p.save!
    expect { p.destroy }.to raise_error
  end
end
