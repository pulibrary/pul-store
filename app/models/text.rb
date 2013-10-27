class Text < Item

  has_many :pages, property: :is_part_of

  # has_metadata 'text_rdf_metadata', type: TextRdfMetadata
  has_metadata 'descMetadata', type: TextRdfMetadata

  # validates :language, presence: true
  
  delegate :toc, to: 'descMetadata', multiple: false
  delegate :description, to: 'descMetadata', multiple: true
  delegate :subject, to: 'descMetadata', multiple: true
  delegate :language, to: 'descMetadata', multiple: true
end
