json.array!(@lae_genres) do |lae_genre|
  json.extract! lae_genre, :id, :pul_label, :dimensions, :dimensions_unit
  json.url lae_genres_url(lae_genre, format: :json)
end
