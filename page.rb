class Page < ActiveFedora::Base
  # Some of this may move into a superclass eventually.

  # Metadata
  include Timestamp
  has_metadata 'descMetadata', type: PageRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  # has_metadata 'techMetadata', type: TechRdfMetadata

  # Delegate attributes
  
  has_attributes :display_label, :datastream => 'descMetadata', multiple: false
  has_attributes :sort_order, :datastream => 'descMetadata', multiple: false
  has_attributes :type, :datastream => 'descMetadata', multiple: false

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

  # Not sure what this needs to do yet. For now it takes a file and the original
  # name.
  def self.upload_to_stage(io, name)
    # will need some exception handling
    path = File.join(PUL_STORE_CONFIG['stage_root'], SecureRandom.hex, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |file|
      file.write(io.read)
    end
    path
  end

end
