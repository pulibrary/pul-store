class Item  < ActiveFedora::Base
  has_metadata 'item_rdf_metadata', type: ItemRdfMetadata

  # validates :title, presence: true
  # validates :sort_title, presence: true
  # validates :type, presence: true

  # validates_with CreatorContributorValidator
  
  # validates :date_modified, presence: true
  # validates :date_uploaded, presence: true

  delegate :type, to: 'item_rdf_metadata', multiple: false
  delegate :title, to: 'item_rdf_metadata', multiple: false
  delegate :sort_title, to: 'item_rdf_metadata', multiple: false
  delegate :creator, to: 'item_rdf_metadata', multiple: false
  delegate :contributor, to: 'item_rdf_metadata', multiple: true
  delegate :date_created, to: 'item_rdf_metadata', multiple: false

  delegate :date_uploaded, to: 'item_rdf_metadata', multiple: false
  delegate :date_modified, to: 'item_rdf_metadata', multiple: false
end
