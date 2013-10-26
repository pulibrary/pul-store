json.array!(@pages) do |page|
  json.extract! page, :label, :type, :sort_order
  json.url page_url(page, format: :json)
end
