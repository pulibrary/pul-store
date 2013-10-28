class Text < Item

  has_many :pages, property: :is_part_of

  has_metadata 'descMetadata', type: TextRdfMetadata # seems to override

  # Should eventually be `validates_associated` once we have an
  # AR model for language
  
  delegate :toc, to: 'descMetadata', multiple: false
  delegate :description, to: 'descMetadata', multiple: true
  delegate :subject, to: 'descMetadata', multiple: true
  delegate :language, to: 'descMetadata', multiple: true
end
