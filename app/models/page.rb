class Page < ActiveFedora::Base

  belongs_to :text, property: :is_part_of

  has_metadata 'page_rdf_metadata', type: PageRdfMetadata

  has_file_datastream 'master_image'
  has_file_datastream 'master_image_fits'
  has_file_datastream 'deliverable_image'
  has_file_datastream 'page_text_content'

  delegate :display_label, to: 'page_rdf_metadata', multiple: false
  delegate :sort_order, to: 'page_rdf_metadata', multiple: false
  delegate :type, to: 'page_rdf_metadata', multiple: false
  delegate :date_uploaded, to: 'page_rdf_metadata', multiple: false
  delegate :date_modified, to: 'page_rdf_metadata', multiple: false
end
