class PulStore::Item  < PulStore::Base
  include PulStore::ExternalMetadataSource

  # Metadata
  has_metadata 'descMetadata', type: PulStore::ItemRdfMetadata

  # Delegate attribs
  has_attributes :title, :datastream => 'descMetadata', multiple: true
  has_attributes :sort_title, :datastream => 'descMetadata', multiple: false
  has_attributes :creator, :datastream => 'descMetadata', multiple: true
  has_attributes :contributor, :datastream => 'descMetadata', multiple: true
  has_attributes :date_created, :datastream => 'descMetadata', multiple: false
  has_attributes :earliest_created, :datastream => 'descMetadata', multiple: false
  has_attributes :latest_created, :datastream => 'descMetadata', multiple: false
  
  # Validations
  validates_presence_of :title, 
    unless: 'self.instance_of?(PulStore::Lae::Folder)'
  validates_presence_of :sort_title, 
    unless: 'self.instance_of?(PulStore::Lae::Folder)'

  def <=>(another)
    if sort_title.is_a? Array # should never be multiple, but is still a list; this is expected to change
      sort_title[0].downcase <=> another.sort_title[0].downcase
    else
      sort_title.downcase <=> another.sort_title.downcase
    end  
  end

  protected

  def has_dates?
    self.has_earliest_and_latest? || self.has_date_created?
  end

  def has_earliest_and_latest?
    ![self.earliest_created, self.latest_created].any? { |d| d.blank? }
  end

  def has_date_created?
    !self.date_created.blank?
  end

end
