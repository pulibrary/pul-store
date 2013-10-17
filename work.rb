class Work < ActiveFedora::Base
  has_metadata 'work_rdf_metadata', type: WorkRdfMetadata

  delegate :title, to: 'work_rdf_metadata', multiple: false
  delegate :creator, to: 'work_rdf_metadata', multiple: false
  delegate :type, to: 'work_rdf_metadata', multiple: false
  delegate :contributor, to: 'work_rdf_metadata', multiple: true
  delegate :date_uploaded, to: 'work_rdf_metadata', multiple: false
  delegate :date_modified, to: 'work_rdf_metadata', multiple: false
end

