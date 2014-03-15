class PulStore::Project < PulStore::Base
  include PulStore::Validations
  # Metadata
  has_metadata 'descMetadata', type: PulStore::ProjectRdfMetadata

  # Delegate attributes
  has_attributes :description, :label, :identifier,
    :datastream => 'descMetadata', multiple: false

  # Associations
  has_many :parts, property: :is_part_of_project, class_name: 'ActiveFedora::Base'

  # Validations
  validates :description, presence: true
  validates :label, presence: true
  validate :validate_project_identifier_uniqueness_on_create, on: :create
  validate :validate_project_identifier_uniqueness_on_update, on: :update

end
