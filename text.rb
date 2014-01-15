module PulStore
  class Text < Item

    include Timestamp

    # Metadata
    has_metadata 'descMetadata', type: TextRdfMetadata

    # Delegate attribs
    has_attributes :abstract, :datastream => 'descMetadata', multiple: true
    has_attributes :alternative_title, :datastream => 'descMetadata', multiple: true
    has_attributes :audience, :datastream => 'descMetadata', multiple: true
    has_attributes :citation, :datastream => 'descMetadata', multiple: true
    has_attributes :description, :datastream => 'descMetadata', multiple: true
    has_attributes :extent, :datastream => 'descMetadata', multiple: true
    has_attributes :has_part, :datastream => 'descMetadata', multiple: true
    has_attributes :language, :datastream => 'descMetadata', multiple: true
    has_attributes :provenance, :datastream => 'descMetadata', multiple: true
    has_attributes :publisher, :datastream => 'descMetadata', multiple: true
    has_attributes :rights, :datastream => 'descMetadata', multiple: true
    has_attributes :series, :datastream => 'descMetadata', multiple: true
    has_attributes :subject, :datastream => 'descMetadata', multiple: true
    has_attributes :toc, :datastream => 'descMetadata', multiple: true

    has_many :pages, as: :page_container, property: :is_part_of, :class_name => 'PulStore::Page'

    # TODO: validations of :dmd_source, :dmd_source_id
    # TODO: validator for language
    
  end
end
