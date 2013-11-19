class Text < Item

  include Timestamp
  include ExternalMetadataSource

  # Metadata
  has_metadata 'descMetadata', type: TextRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'srcMetadata', type: ExternalXmlMetadata



  # TODO: Add srcMetadata, which is just a copy of the marcxml

  # Delegate attribs
  has_attributes :toc, :datastream => 'descMetadata', multiple: false
  has_attributes :description, :datastream => 'descMetadata', multiple: true
  has_attributes :subject, :datastream => 'descMetadata', multiple: true
  has_attributes :language, :datastream => 'descMetadata', multiple: true

  # Associations
  has_many :pages, property: :is_part_of

  # TODO: validations of :dmd_source, :dmd_source_id
  # TODO: validator for language

  def src_metadata=(io)
    self.srcMetadata.content=io
  end

  def src_metadata
    self.srcMetadata.content
  end
  
end
