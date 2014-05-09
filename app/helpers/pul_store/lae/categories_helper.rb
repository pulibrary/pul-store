module PulStore::Lae::CategoriesHelper

  def list_all_categories_as_select_list
    return PulStore::Lae::Category.all.map { |c| [c.label, c.label] }
  end

  def get_category_id_by_label(label)
    PulStore::Lae::Category.where(label: label).first.id
  end
end
