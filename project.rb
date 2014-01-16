require File.expand_path('../lib/active_fedora/pid', __FILE__)

class PulStore::Project < PulStore::Base

  # Metadata
  has_metadata 'descMetadata', type: PulStore::ProjectRdfMetadata

  # Delegate attributes
  has_attributes :description, :display_label, :project_identifier,
    :datastream => 'descMetadata', multiple: false

  # Relationships
  # Note that `dependent: :restrict_with_exception` does absolutely nothing right now!
  # , dependent: :restrict_with_exception
  has_many :items, property: :is_part_of_project, :class_name => 'PulStore::Item'
  has_many :boxes, property: :is_part_of_project, :class_name => 'PulStore::Item'

  # Validations
  validates :description, presence: true
  validates :display_label, presence: true
  validates :project_identifier, presence: true

end
