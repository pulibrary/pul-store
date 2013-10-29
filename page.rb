class Page < ActiveFedora::Base
  # Some of this may move into a superclass eventually. Should also be saveable.

  # Metadata
  include Timestamp
  has_metadata 'descMetadata', type: PageRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  # has_metadata 'techMetadata', type: TechRdfMetadata

  # Delegate attributes
  delegate :display_label, to: 'descMetadata', multiple: false
  delegate :sort_order, to: 'descMetadata', multiple: false
  delegate :type, to: 'descMetadata', multiple: false

  # Associations
  belongs_to :text, property: :is_part_of

  # Validations
  validates :type, inclusion: { 
    in: %w(Page),
    message: "type must be 'Page'"
  }
  validates :sort_order, numericality: true

  # Streams
  has_file_datastream 'masterImage'
  has_file_datastream 'masterImageFits'
  has_file_datastream 'deliverableImage'
  has_file_datastream 'pageTextContent'


  # Not yet sure how this will work. Presumably the controller will need to
  # let a master_image through, then it goes to a staging area, then what?
  def master_image=(path)
    self.masterImage.content=File.open(path)
  end

  def master_image
    self.masterImage.content
  end

end
