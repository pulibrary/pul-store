class Page < ActiveFedora::Base

  # Some of this may move into a superclass eventually. Should also be saveable.

  validates :type, inclusion: { 
    in: %w(Page),
    message: "type must be 'Page'"
  }
  validates :sort_order, numericality: true

  belongs_to :text, property: :is_part_of

  has_metadata 'descMetadata', type: PageRdfMetadata

  has_file_datastream 'master_image'
  has_file_datastream 'master_image_fits'
  has_file_datastream 'deliverable_image'
  has_file_datastream 'page_text_content'

  delegate :display_label, to: 'descMetadata', multiple: false
  delegate :sort_order, to: 'descMetadata', multiple: false
  delegate :type, to: 'descMetadata', multiple: false

  # TODO: these should move into a separate stream (needed by, e.g. page, 
  # and not really descriptive)
  # see http://stackoverflow.com/a/11464418/714478
  delegate :date_uploaded, to: 'page_rdf_metadata', multiple: false
  delegate :date_modified, to: 'page_rdf_metadata', multiple: false
end
