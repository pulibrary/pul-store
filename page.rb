require File.expand_path('../lib/active_fedora/pid', __FILE__)

module PulStore
  class Page < ActiveFedora::Base
    include PulStore::Timestamp
    include PulStore::CharacterizationSupport
    include PulStore::Stage

    # Metadata
    has_metadata 'descMetadata', type: PulStore::PageRdfMetadata
    has_metadata 'provMetadata', type: PulStore::ProvRdfMetadata
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
    belongs_to :page_container, property: :is_part_of, class_name: 'PulStore::Item'
    # This is a workaround AF's lack of polymorphic associations.
    alias :text= :page_container=
    alias :text :page_container
    alias :folder= :page_container=
    alias :folder :page_container

# 17:33 < jcoyne> belongs_to :page_container, property: :is_part_of, class_name: 'ActiveFedora::Base'
# 17:34 < jcoyne> Then your #page_container  method contains either the Folder or a Text
# 17:34 < jcoyne> you wouldn't have to ensure only one is set.
# 17:34 < jcoyne> but you have to use p.page_container instead of p.text
# 17:34 -!- acozine [~Adium@2601:2:5d80:e47:1dbe:b76:36d6:54c0] has joined #projecthydra
# 17:34 < jcoyne> jpstroop ^
# 17:35 < jpstroop> yeah, I was doing that...it bugged me...
# 17:36 < jpstroop> think I'll go with the former approach for now...
# 17:36 < jpstroop> but, again, thanks!
# 17:36 < jcoyne> you could then create aliases:  alias :text= :page_container=; alias :text :page_container
# 17:36 < jpstroop> ahh!
# 17:37  * jpstroop rolls back the rollbacks


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
end
