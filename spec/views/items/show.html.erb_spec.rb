require 'spec_helper'

describe "items/show" do
  before(:each) do
    @item = assign(:item, stub_model(Item,
      :type => "Type",
      :title => "Title",
      :sort_title => "Sort Title",
      :creator => "Creator",
      :contributor => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/Title/)
    rendered.should match(/Sort Title/)
    rendered.should match(/Creator/)
    rendered.should match(//)
  end
end
