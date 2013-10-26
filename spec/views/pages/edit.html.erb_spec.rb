require 'spec_helper'

describe "pages/edit" do
  before(:each) do
    @page = assign(:page, stub_model(Page,
      :label => "MyString",
      :type => "",
      :sort_order => 1
    ))
  end

  it "renders the edit page form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", page_path(@page), "post" do
      assert_select "input#page_label[name=?]", "page[label]"
      assert_select "input#page_type[name=?]", "page[type]"
      assert_select "input#page_sort_order[name=?]", "page[sort_order]"
    end
  end
end
