class PulStore::Lae::Subject < ActiveRecord::Base
  # :label
  # :uri
  belongs_to :category, class_name: "PulStore::Lae::Category"
end
