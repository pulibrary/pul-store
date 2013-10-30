class Item  < ActiveFedora::Base

  # Metadata
  include Timestamp
  has_metadata 'descMetadata', type: ItemRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata

#   has_attributes :event_series, :datastream => :descMetadata, :at => [:series],
# :multiple => true

  # Delegate attribs
  has_attributes :type, :datastream => 'descMetadata', multiple: false
  has_attributes :title, :datastream => 'descMetadata', multiple: false
  has_attributes :sort_title, :datastream => 'descMetadata', multiple: false
  has_attributes :creator, :datastream => 'descMetadata', multiple: false
  has_attributes :contributor, :datastream => 'descMetadata', multiple: true
  has_attributes :date_created, :datastream => 'descMetadata', multiple: false

  # Associations

  # Validations
  validates :title, presence: true
  validates :sort_title, presence: true
  # Below will need a custom validator once we have a type AR model
  validates :type, presence: true
  #  BROKEN: validates_with CreatorContributorValidator

  # Streams


  
  def <=>(another)
    if sort_title.is_a? Array # should never be multiple, but is still a list; this is expected to change
      sort_title[0].downcase <=> another.sort_title[0].downcase
    else
      sort_title.downcase <=> another.sort_title.downcase
    end  
  end

end
