class Text < Item

  has_many :pages, property: :is_part_of

  has_metadata 'text_rdf_metadata', type: TextRdfMetadata

  # validates :language, presence: true
  
  # delegate :type, to: 'text_rdf_metadata', multiple: false
  # delegate :title, to: 'text_rdf_metadata', multiple: false
  # delegate :sort_title, to: 'text_rdf_metadata', multiple: false
  # delegate :creator, to: 'text_rdf_metadata', multiple: false
  # delegate :contributor, to: 'text_rdf_metadata', multiple: true

  delegate :toc, to: 'text_rdf_metadata', multiple: false
  delegate :description, to: 'text_rdf_metadata', multiple: true
  delegate :subject, to: 'text_rdf_metadata', multiple: true
  delegate :language, to: 'text_rdf_metadata', multiple: true
end
