require 'spec_helper'

describe "PulStore::Lae::SubjectsHelper", :type => :helper do

  describe "#category_label_for_subject_label" do

    it "should get the correct category label for a subject label" do
      su = "Urban-rural migration"
      cat = "Urban issues"
      expect(helper.category_label_for_subject_label(su)).to eq(cat)
    end

  end

end
