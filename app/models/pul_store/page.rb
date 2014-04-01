class PulStore::Page < PulStore::Base
  include PulStore::Validations
  include PulStore::CharacterizationSupport
  include PulStore::Stage
  include PulStore::Lae::Permissions

  # Metadata
  has_metadata 'descMetadata', type: PulStore::PageRdfMetadata
  has_metadata 'masterTechMetadata', type: PulStore::MasterImageFitsDatastream

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
  belongs_to :folder, property: :is_part_of, class_name: 'PulStore::Lae::Folder'
  belongs_to :text, property: :is_part_of, class_name: 'PulStore::Text'
  # but only one!

  # Validations
  validates :sort_order, numericality: true
  validate :validate_page_belongs_to_exactly_one_item

  # Streams
  has_file_datastream 'masterImage'
  has_file_datastream 'deliverableImage'
  has_file_datastream 'pageOcr'

  def master_image=(path_string_or_io)
    self.ingest_from_path_string_or_io(path_string_or_io)
  end

  def master_image
    self.masterImage.content
  end

  def deliverable_image=(path_string_or_io)
    self.ingest_from_path_string_or_io(path_string_or_io)
  end

  def deliverable_image
    self.deliverableImage.content
  end

  def master_tech_metadata=(path_string_or_io)
    self.ingest_from_path_string_or_io(path_string_or_io)
  end

  def master_tech_metadata
    self.masterTechMetadata.content
  end

  def page_ocr=(path_string_or_io)
    self.ingest_from_path_string_or_io(path_string_or_io)
  end

  def page_ocr
    self.pageOcr.content
  end

  protected

  # Ingest a String, StringIO, IO, or file from a path.
  # Options: 
  #   :stream_name. Use when the calling method is not the snake_case name of the file_datastream.
  def ingest_from_path_string_or_io(path_s_or_io, opts={})
    opts[:stream_name] ||= caller_locations(1,1)[0].label.camelize(:lower).chomp('=')
    content = nil
    if path_s_or_io.kind_of?(String) && File.exists?(path_s_or_io)
      content = File.open(path_s_or_io)
    else 
      content = path_s_or_io # AF doesn't seem to mind String or IO/StringIO
    end
    self.send("#{opts[:stream_name]}").send('content=', content)
  end

end
