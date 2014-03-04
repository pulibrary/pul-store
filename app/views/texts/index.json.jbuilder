
# this is probably broken, need to be updated w/ latest attributes, most of which are arrays, etc.
json.array!(@texts) do |text|

  json.extract! text, :description, :subject, :language, :toc

  json.url text_url(text, format: :json)
  
end
