module PulStore::Lae::SubjectsHelper

  def category_label_for_subject_label(subject_label)
    PulStore::Lae::Subject.find_by(label: subject_label).category.label
  end

   def category_id_for_subject_label(subject_label)
    PulStore::Lae::Subject.find_by(label: subject_label).category.id
  end


  def list_all_subjects_as_select_list
    return PulStore::Lae::Subject.all.map { |s| [s.label, s.label] }
  end

  def get_all_subject_labels_by_category_id(id)
    return Array.new { PulStore::Lae::Subject.find_by(category_id: id).label }
  end

end
