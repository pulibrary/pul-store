class Text < Item

  include Timestamp

  # Metadata
  has_metadata 'descMetadata', type: TextRdfMetadata
  
  # These inherit from Item:
  # has_metadata 'provMetadata', type: ProvRdfMetadata
  # has_metadata 'srcMetadata', type: ExternalXmlMetadata

  # Delegate attribs
  
  has_attributes :alternative_title, :datastream => 'descMetadata', multiple: true
  has_attributes :toc, :datastream => 'descMetadata', multiple: false
  has_attributes :description, :datastream => 'descMetadata', multiple: true
  has_attributes :subject, :datastream => 'descMetadata', multiple: true
  has_attributes :language, :datastream => 'descMetadata', multiple: true

  # Associations
  has_many :pages, property: :is_part_of

  # TODO: validations of :dmd_source, :dmd_source_id
  # TODO: validator for language


  
end
