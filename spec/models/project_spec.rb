require 'spec_helper'

describe Project do
  it "has a valid factory" do
    FactoryGirl.create(:project).should be_valid
  end

  it "can not be deleted if it has associated items" do
    p = FactoryGirl.create(:project)
    i = FactoryGirl.create(:item)
    p.items << i
    expect { Project.find(p.pid).delete }.to raise_error ActiveRecord::DeleteRestrictionError
  end
end
