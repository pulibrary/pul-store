require 'spec_helper'

describe "items/index" do
  before(:each) do
    assign(:items, [
      stub_model(Item,
        :type => "Type",
        :title => "Title",
        :sort_title => "Sort Title",
        :creator => "Creator",
        :contributor => ""
      ),
      stub_model(Item,
        :type => "Type",
        :title => "Title",
        :sort_title => "Sort Title",
        :creator => "Creator",
        :contributor => ""
      )
    ])
  end

  it "renders a list of items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Sort Title".to_s, :count => 2
    assert_select "tr>td", :text => "Creator".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
