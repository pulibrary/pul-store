module LanguagesHelper
  def list_all_languages_as_select_list
    vals = Language.all.map(&:label)
    vals.unshift("Spanish", "English", "Portuguese")
    language_select_list = vals.map { |v| [v, v] }
    return language_select_list
  end


end
