class Work < ActiveFedora::Base
  # before_save :stamp
  # see: http://rdoc.info/github/projecthydra/active_fedora/ActiveFedora/Callbacks
  # before_validation :stamp
  before_save do
    if self.date_uploaded == [] # this may change??
      self.date_uploaded = DateTime.now.utc
    end
    self.date_modified = DateTime.now.utc
  end

  has_metadata 'work_rdf_metadata', type: WorkRdfMetadata

  # TODO: needs to get a PID, date_modified and possibly date_uploaded just 
  # before save. See http://stackoverflow.com/a/6770431/714478

  validates :title, presence: true
  validates :sort_title, presence: true
  validates :type, presence: true

  validates_with CreatorContributorValidator
  
  validates :date_modified, presence: true
  validates :date_uploaded, presence: true
  # validates :pid, presence: true
  # validates :pid, exclusion: { in: ['__DO_NOT_USE__'] }

  delegate :type, to: 'work_rdf_metadata', multiple: false
  delegate :title, to: 'work_rdf_metadata', multiple: false
  delegate :sort_title, to: 'work_rdf_metadata', multiple: false
  delegate :creator, to: 'work_rdf_metadata', multiple: false
  delegate :contributor, to: 'work_rdf_metadata', multiple: true
  delegate :date_created, to: 'work_rdf_metadata', multiple: false

  delegate :date_uploaded, to: 'work_rdf_metadata', multiple: false
  delegate :date_modified, to: 'work_rdf_metadata', multiple: false

  def <=>(another)
    if sort_title.is_a? Array # should never be multiple, but is still a list; this is expected to change
      sort_title[0].downcase <=> another.sort_title[0].downcase
    else
      sort_title.downcase <=> another.sort_title.downcase
    end  
  end

end

