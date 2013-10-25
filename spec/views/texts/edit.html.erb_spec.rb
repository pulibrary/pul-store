require 'spec_helper'

describe "texts/edit" do
  before(:each) do
    @text = assign(:text, stub_model(Text,
      :description => "",
      :subject => "",
      :language => "",
      :toc => ""
    ))
  end

  it "renders the edit text form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", text_path(@text), "post" do
      assert_select "input#text_description[name=?]", "text[description]"
      assert_select "input#text_subject[name=?]", "text[subject]"
      assert_select "input#text_language[name=?]", "text[language]"
      assert_select "input#text_toc[name=?]", "text[toc]"
    end
  end
end
