require File.expand_path('../lib/active_fedora/pid', __FILE__)

class Page < ActiveFedora::Base
  # Some of this may move into a superclass eventually.
  include Timestamp
  include CharacterizationSupport
  include Stage

  # Metadata
  has_metadata 'descMetadata', type: PageRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'masterTechMetadata', type: MasterImageFitsDatastream

  # Delegate attributes
  has_attributes :display_label, :datastream => 'descMetadata', multiple: false
  has_attributes :sort_order, :datastream => 'descMetadata', multiple: false

  # We keep these here (instead of with the CharacterizationSupport mixin)
  # because other types might have different datastreams in which they want to 
  # store their tech metadata. At least for now....
  has_attributes :master_mime_type, :datastream => 'masterTechMetadata', multiple: false
  has_attributes :master_well_formed, :datastream => 'masterTechMetadata', multiple: false
  has_attributes :master_valid, :datastream => 'masterTechMetadata', multiple: false
  has_attributes :master_last_modified, :master_format_label, :master_file_size, 
    :master_last_modified, :master_filename, :master_md5checksum, 
    :master_status_message, :master_byte_order, :master_compression, 
    :master_width, :master_height, :master_color_space, :master_profile_name, 
    :master_profile_version, :master_orientation, :master_color_map, 
    :master_image_producer, :master_capture_device, :master_scanning_software, 
    :master_exif_version, :master_gps_timestamp, :master_latitude, 
    :master_longitude,
    :datastream => 'masterTechMetadata', multiple: true

  # Associations
  belongs_to :text, property: :is_part_of

  # Validations
  validates :sort_order, numericality: true

  # Streams
  has_file_datastream 'masterImage'
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

  def master_tech_md=(io)
    self.masterTechMetadata.content=io
  end

  def master_tech_md
    self.masterTechMetadata.content
  end

end
