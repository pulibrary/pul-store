class Text < Item

  # Metadata
  has_metadata 'descMetadata', type: TextRdfMetadata # seems to override

  # Delegate attribs
  has_attributes :toc, :datastream => 'descMetadata', multiple: false
  has_attributes :description, :datastream => 'descMetadata', multiple: true
  has_attributes :subject, :datastream => 'descMetadata', multiple: true
  has_attributes :language, :datastream => 'descMetadata', multiple: true

  # Associations
  has_many :pages, property: :is_part_of

  # Validations
  # Language should have a validator once we have an AR model for language 
  # (note that `validates_associated` doesn't seem to be impl for ActiveFedora)

  # Streams
  
end
