json.array!(@topics) do |topic|
  json.extract! topic, :id, :value
end
