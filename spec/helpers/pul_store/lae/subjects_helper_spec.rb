require 'spec_helper'

describe "PulStore::Lae::SubjectsHelper" do

  describe "#category_label_for_subject_label" do

    it "should get the correct category label for a subject label" do
      su = "Urban-rural migration"
      cat = "Urban issues"
      helper.category_label_for_subject_label(su).should == cat
    end

  end

end
