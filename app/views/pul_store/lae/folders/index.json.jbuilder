json.array!(@folders) do |folder|
  json.extract! folder, :barcode, :genre, :title, :pid  # needs filling out!
  json.url lae_folder_url(folder, format: :json)
end
