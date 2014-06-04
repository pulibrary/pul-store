module PulStore::Lae::CategoriesHelper

  def list_all_categories_as_select_list
    return PulStore::Lae::Category.all.map { |c| [c.label, c.label] }
  end

  # very slick options_for_select strategy 
  # http://stackoverflow.com/questions/5052889/ruby-on-rails-f-select-options-with-custom-attributes
  def list_all_categories_as_select_list_with_data
    return PulStore::Lae::Category.all.map { |c| [c.label, c.label, {'data-category-id'=>c.id }]  }
  end

  def get_category_id_by_label(label)
    PulStore::Lae::Category.where(label: label).first.id
  end
end
