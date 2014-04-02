module PulStore::Lae::SubjectsHelper

  def category_label_for_subject_label(subject_label)
    PulStore::Lae::Subject.find_by(label: subject_label).category.label
  end

end
