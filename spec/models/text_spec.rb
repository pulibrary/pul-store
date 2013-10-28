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

end
