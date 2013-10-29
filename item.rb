class Item  < ActiveFedora::Base

  # Metadata
  include Timestamp
  has_metadata 'descMetadata', type: ItemRdfMetadata
  has_metadata 'provMetadata', type: ProvRdfMetadata

  # Delegate attribs
  delegate :type, to: 'descMetadata', multiple: false
  delegate :title, to: 'descMetadata', multiple: false
  delegate :sort_title, to: 'descMetadata', multiple: false
  delegate :creator, to: 'descMetadata', multiple: false
  delegate :contributor, to: 'descMetadata', multiple: true
  delegate :date_created, to: 'descMetadata', multiple: false

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
