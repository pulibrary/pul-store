class PulStore::Lae::Category < ActiveRecord::Base
  # :label
  has_many :subjects, class_name: "PulStore::Lae::Subject"
end
