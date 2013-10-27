class Item  < ActiveFedora::Base
  has_metadata 'descMetadata', type: ItemRdfMetadata

  validates :title, presence: true
  validates :sort_title, presence: true
  validates :type, presence: true

  # validates_with CreatorContributorValidator
  
  # validates :date_modified, presence: true
  # validates :date_uploaded, presence: true

  delegate :type, to: 'descMetadata', multiple: false
  delegate :title, to: 'descMetadata', multiple: false
  delegate :sort_title, to: 'descMetadata', multiple: false
  delegate :creator, to: 'descMetadata', multiple: false
  delegate :contributor, to: 'descMetadata', multiple: true
  delegate :date_created, to: 'descMetadata', multiple: false

  # TODO: these should move into a separate stream (needed by, e.g. page, 
  # and not really descriptive)
  delegate :date_uploaded, to: 'descMetadata', multiple: false
  delegate :date_modified, to: 'descMetadata', multiple: false
end
