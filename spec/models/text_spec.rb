require 'spec_helper'
# start here:
# http://everydayrails.com/2012/03/19/testing-series-rspec-models-factory-girl.html

describe Text do

  it 'has a valid factory' do
    FactoryGirl.create(:text).should be_valid
  end

  it 'can have many pages' do
    expected_page_count = rand(2..5)
    t = FactoryGirl.create(:text)
    expected_page_count.times do
      p = FactoryGirl.build(:page)
      p.text = t
      p.save
    end
    t.pages.length.should == expected_page_count
  end

  it 'gets a timestamp on save' do
    t = FactoryGirl.create(:text)
    t.date_modified.should_not be_nil

    u = FactoryGirl.build(:text)
    u.save
    u.date_modified.should_not be_nil
  end

  it 'has a date uploaded that does not change' do
    t = FactoryGirl.create(:text)
    d = t.date_uploaded
    t.title ="Changed title"
    t.save
    t.date_uploaded.should == d

  end

  it 'has a list of dates when it was modified' do
    t = FactoryGirl.create(:text)
    d = t.date_uploaded
    t.title ="Changed title"
    t.save
    t.date_modified.length.should == 2
  end

end
