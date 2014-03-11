class PulStore::Lae::Topic < ActiveRecord::Base
  # :value
  has_and_belongs_to_many :subjects, class_name: "PulStore::Lae::Subject"
end
