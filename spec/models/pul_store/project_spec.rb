require 'spec_helper'

describe PulStore::Project, :type => :model do
  it "can not be deleted if it has associated children" do
    p = PulStore::Project.last
    i = FactoryGirl.create(:item)
    p.parts << i
    p.save!
    expect(p.destroy).to be_falsey
  end

  it "must have a unique indentifier" do
    ident = "xyz"
    FactoryGirl.create(:project, identifier: ident)
    expect { FactoryGirl.create(:project, identifier: ident) }.to raise_error
  end
end

