require 'spec_helper'

describe "pages/new" do
  before(:each) do
    assign(:page, stub_model(Page,
      :label => "MyString",
      :type => "",
      :sort_order => 1
    ).as_new_record)
  end

  it "renders new page form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", pages_path, "post" do
      assert_select "input#page_label[name=?]", "page[label]"
      assert_select "input#page_type[name=?]", "page[type]"
      assert_select "input#page_sort_order[name=?]", "page[sort_order]"
    end
  end
end
