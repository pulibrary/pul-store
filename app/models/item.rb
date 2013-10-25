class Item  < ActiveFedora::Base
  has_metadata 'descMetadata', type: ItemRdfMetadata

  delegate :type, to: 'descMetadata', multiple: false
  delegate :title, to: 'descMetadata', multiple: false
  delegate :sort_title, to: 'descMetadata', multiple: false
  delegate :creator, to: 'descMetadata', multiple: false
  delegate :contributor, to: 'descMetadata', multiple: true
  delegate :date_created, to: 'descMetadata', multiple: false

  delegate :date_uploaded, to: 'descMetadata', multiple: false
  delegate :date_modified, to: 'descMetadata', multiple: false
end
