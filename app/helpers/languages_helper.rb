module LanguagesHelper
  def list_all_languages_as_select_list(opts={})
    vals = Language.all.map(&:label)
    
    move_lae_langs_to_front(vals) if opts[:project] == 'lae'

    language_select_list = vals.map { |v| [v, v] }
    return language_select_list
  end

  private

  def move_lae_langs_to_front(lst)
    ["Portuguese", "English", "Spanish"].each do |l|
      lst.delete(l)
      lst.unshift(l)
    end
    lst
  end

end
