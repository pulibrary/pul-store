class Text < Item
  has_metadata 'descMetadata', type: TextRdfMetadata

  delegate :toc, to: 'descMetadata', multiple: false
  delegate :description, to: 'descMetadata', multiple: true
  delegate :subject, to: 'descMetadata', multiple: true
  delegate :language, to: 'descMetadata', multiple: true
end
