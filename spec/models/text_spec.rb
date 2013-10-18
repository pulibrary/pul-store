require 'spec_helper'
# start here:
# http://everydayrails.com/2012/03/19/testing-series-rspec-models-factory-girl.html

describe Text do

  it 'has a valid factory' do
    t = FactoryGirl.create(:text)
    t.should be_valid
  end
end