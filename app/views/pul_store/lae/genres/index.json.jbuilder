json.array!(@lae_genres) do |lae_genre|
  json.extract! lae_genre, :id, :pul_label, :uri
end
