require 'spec_helper'
# start here:
# http://everydayrails.com/2012/03/19/testing-series-rspec-models-factory-girl.html

# TODO: consider moving to afmodels??

describe Work do
  it "has a valid factory" do
    FactoryGirl.create(:work).should be_valid
  end

  it "is invalid without a title" do
    w = FactoryGirl.build(:work, title: nil)
    w.should_not be_valid

    expect { 
      FactoryGirl.create(:work, title: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:work, title: 'My Book') 
    }.to_not raise_error
  end

  it "is invalid without a sort title" do
    expect { 
      FactoryGirl.create(:work, sort_title: nil) 
    }.to raise_error ActiveFedora::RecordInvalid

    expect { 
      FactoryGirl.create(:work, sort_title: 'My Book') 
    }.to_not raise_error
  end

  it "sorts by sort_title by default" do
    Work.delete_all
    ['cats', 'elephants', 'dogs'].each do |a|
       FactoryGirl.create(:work, sort_title: "All about #{a}") 
    end
    works = Work.all.sort
    if works[0].sort_title.is_a? Array 
      # should never be multiple, but is still a list; this is expected to change
      works[0].sort_title[0].should == "All about cats"
      works[1].sort_title[0].should == "All about dogs"
      works[2].sort_title[0].should == "All about elephants"
    else
      works[0].sort_title.should == "All about cats"
      works[1].sort_title.should == "All about dogs"
      works[2].sort_title.should == "All about elephants"
    end
  end

  it "may have zero or one creators"  do
    FactoryGirl.create(:work, creator: "Stroop, Jon").should be_valid
  end

  it "may not have more than one creator"  do
    expect { 
      FactoryGirl.create(:work, creator: ["Stroop, Jon", "Ellis, Shaun"])
    }.to raise_error ActiveFedora::RecordInvalid
  end

  it "may mave two or more contributors"  do
    cs = ["Stroop, Jon", "Ellis, Shaun"]
    cs << "Reiss, Kevin"
    FactoryGirl.create(:work, contributor: cs).should be_valid
  end

  it "must have zero creators if there are contributors" do
    cs = ["Stroop, Jon", "Ellis, Shaun"]
    expect { 
      FactoryGirl.create(:work, creator: "Reiss, Kevin", contributor: cs)
    }.to raise_error ActiveFedora::RecordInvalid
  end 

  it "has a date uploaded and date modified after it is saved" do
    w = Work.new(title:"The book", sort_title:"book", type: "Work")
    w.date_uploaded.should == []
    w.date_modified.should == []
    w.save!
    w.date_uploaded.should_not == [] # hmm....
    w.date_modified.should_not == [] # hmm....
  end

  it "has a identifier after it is saved ???"

  it "gets a new a date modified after it is modified"
end
