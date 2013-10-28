class Page < ActiveFedora::Base
  include Timestamp
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

end
