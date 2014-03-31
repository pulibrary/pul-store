module PulStore::Lae::CategoriesHelper

  def list_all_categories_as_select_list
    return PulStore::Lae::Category.all.map { |c| [c.id, c.label] }
  end


end
