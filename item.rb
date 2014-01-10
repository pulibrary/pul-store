require File.expand_path('../lib/active_fedora/pid', __FILE__)

module PulStore
  class Item  < ActiveFedora::Base

    include Timestamp
    include ExternalMetadataSource

    # Metadata
    has_metadata 'descMetadata', type: ItemRdfMetadata
    has_metadata 'provMetadata', type: ProvRdfMetadata

    # Delegate attribs
    has_attributes :title, :datastream => 'descMetadata', multiple: true
    has_attributes :sort_title, :datastream => 'descMetadata', multiple: false
    has_attributes :creator, :datastream => 'descMetadata', multiple: true
    has_attributes :contributor, :datastream => 'descMetadata', multiple: true
    has_attributes :date_created, :datastream => 'descMetadata', multiple: false

    # Associations
    belongs_to :project, property: :is_part_of_project, :class_name => 'PulStore::Project'

    # Validations
    validates :title, presence: true
    validates :sort_title, presence: true
    validates :project, presence: true

    #  BROKEN: validates_with CreatorContributorValidator


    def <=>(another)
      if sort_title.is_a? Array # should never be multiple, but is still a list; this is expected to change
        sort_title[0].downcase <=> another.sort_title[0].downcase
      else
        sort_title.downcase <=> another.sort_title.downcase
      end  
    end

  end
end
