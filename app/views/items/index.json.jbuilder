json.array!(@items) do |item|
  json.extract! item, :type, :title, :sort_title, :creator, :contributor, :date_created
  json.url item_url(item, format: :json)
end
