class Page < ActiveFedora::Base
  has_metadata 'page_rdf_metadata', type: PageRdfMetadata

  # TODO: needs validations

  has_file_datastream 'master_image'
  has_file_datastream 'deliverable_image'

  belongs_to :text, property: :is_part_of

  delegate :display_label, to: 'page_rdf_metadata', unique: :true
  delegate :sort_order, to: 'page_rdf_metadata', unique: :true
end
