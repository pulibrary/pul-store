class PulStore::Project < PulStore::Base

  # Metadata
  has_metadata 'descMetadata', type: PulStore::ProjectRdfMetadata

  # Delegate attributes
  has_attributes :description, :label, :identifier,
    :datastream => 'descMetadata', multiple: false

  # Associations
  has_many :parts, property: :is_part_of_project, :class_name => 'ActiveFedora::Base'

  # Validations
  validates :description, presence: true
  validates :label, presence: true
  validates :identifier, presence: true

end
