json.array!(@texts) do |text|
  json.extract! text, :description, :subject, :language, :toc
  json.url text_url(text, format: :json)
end
