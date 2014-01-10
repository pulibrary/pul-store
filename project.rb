require File.expand_path('../lib/active_fedora/pid', __FILE__)

class Project < ActiveFedora::Base
  # Some of this may move into a superclass eventually.
  include Timestamp
  
  # Metadata
  has_metadata 'descMetadata', type: ProjectRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata

  # Delegate attributes
  has_attributes :description, :datastream => 'descMetadata', multiple: false
  has_attributes :display_label, :datastream => 'descMetadata', multiple: false
  has_attributes :project_identifier, :datastream => 'descMetadata', multiple: false

  # Relationships
  has_many :items, dependent: :restrict_with_exception, property: :is_part_of_project, :class_name => 'Item' # subclasses ok?

  # Validations
  validates :description, presence: true
  validates :display_label, presence: true
  validates :project_identifier, presence: true


end
