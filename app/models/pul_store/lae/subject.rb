class PulStore::Lae::Subject < ActiveRecord::Base
  # :value
  has_and_belongs_to_many :topics, class_name: "PulStore::Lae::Topic"
end
