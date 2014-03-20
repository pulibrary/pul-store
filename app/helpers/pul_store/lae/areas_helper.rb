module PulStore::Lae::AreasHelper

  def list_all_areas_as_select_list
    area_select_list = PulStore::Lae::Area.all.map { |a| [a.label, a.label] }
    return area_select_list
  end


end
