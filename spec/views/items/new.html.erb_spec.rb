require 'spec_helper'

describe "items/new" do
  before(:each) do
    assign(:item, stub_model(Item,
      :type => "",
      :title => "MyString",
      :sort_title => "MyString",
      :creator => "MyString",
      :contributor => ""
    ).as_new_record)
  end

  it "renders new item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", items_path, "post" do
      assert_select "input#item_type[name=?]", "item[type]"
      assert_select "input#item_title[name=?]", "item[title]"
      assert_select "input#item_sort_title[name=?]", "item[sort_title]"
      assert_select "input#item_creator[name=?]", "item[creator]"
      assert_select "input#item_contributor[name=?]", "item[contributor]"
    end
  end
end
