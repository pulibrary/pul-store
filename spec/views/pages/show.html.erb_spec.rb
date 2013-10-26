require 'spec_helper'

describe "pages/show" do
  before(:each) do
    @page = assign(:page, stub_model(Page,
      :label => "Label",
      :type => "Type",
      :sort_order => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Label/)
    rendered.should match(/Type/)
    rendered.should match(/1/)
  end
end
