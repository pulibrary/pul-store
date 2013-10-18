require 'spec_helper'
# start here:
# http://everydayrails.com/2012/03/19/testing-series-rspec-models-factory-girl.html

# TODO: consider moving to afmodels??

describe Work do
  it "has a valid factory"
  it "has a title"
  it "has a sort title"
  it "is sortable by sort_title"
  it "may have zero or one creators" 
  it "has zero creators if there are contributors" 
  it "has more than one contributors if there are any"
  it "has a pid after it is saved"
  it "has a date uploaded after it is saved"
  it "has a date modified after it is saved"
end
