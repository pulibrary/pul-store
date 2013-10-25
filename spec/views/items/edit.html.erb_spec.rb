require 'spec_helper'

describe "items/edit" do
  before(:each) do
    @item = assign(:item, stub_model(Item,
      :type => "",
      :title => "MyString",
      :sort_title => "MyString",
      :creator => "MyString",
      :contributor => ""
    ))
  end

  it "renders the edit item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", item_path(@item), "post" do
      assert_select "input#item_type[name=?]", "item[type]"
      assert_select "input#item_title[name=?]", "item[title]"
      assert_select "input#item_sort_title[name=?]", "item[sort_title]"
      assert_select "input#item_creator[name=?]", "item[creator]"
      assert_select "input#item_contributor[name=?]", "item[contributor]"
    end
  end
end
