class Work < ActiveFedora::Base
  has_metadata 'work_rdf_metadata', type: WorkRdfMetadata

  # TODO: needs to get a PID, date_modified and possibly date_uploaded just before save
  # see http://stackoverflow.com/a/6770431/714478

  validates :type, presence: true
  validates :title, presence: true
  validates :pid, presence: true
  validates_with CreatorContributorValidator

  delegate :type, to: 'work_rdf_metadata', multiple: false
  delegate :title, to: 'work_rdf_metadata', multiple: false
  delegate :creator, to: 'work_rdf_metadata', multiple: false
  delegate :contributor, to: 'work_rdf_metadata', multiple: true
  delegate :date_uploaded, to: 'work_rdf_metadata', multiple: false
  delegate :date_modified, to: 'work_rdf_metadata', multiple: false
end


