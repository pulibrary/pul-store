class Text < Item

  # Metadata
  has_metadata 'descMetadata', type: TextRdfMetadata # seems to override

  # Delegate attribs
  delegate :toc, to: 'descMetadata', multiple: false
  delegate :description, to: 'descMetadata', multiple: true
  delegate :subject, to: 'descMetadata', multiple: true
  delegate :language, to: 'descMetadata', multiple: true

  # Associations
  has_many :pages, property: :is_part_of

  # Validations
  # Language should have a validator once we have an AR model for language 
  # (note that `validates_associated` doesn't seem to be impl for ActiveFedora)

  # Streams
  
end
