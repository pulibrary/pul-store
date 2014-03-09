module PulStore::Lae::GenresHelper

  def list_all_genres_as_select_list
    genre_select_list = PulStore::Lae::Genre.all.map { |genre| [genre.pul_label, genre.pul_label] }
    return genre_select_list
  end


end
