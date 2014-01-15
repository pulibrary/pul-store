require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')

class PulStore::Lae::Folder < PulStore::Item
  include Timestamp
  include Validations
  include PulStore::Lae::Provenance

  @@prelim_elements = [:barcode, :extent, :genre]
  def self.prelim_elements
    @@prelim_elements
  end

  @@required_elements = (
    [:date_created, :rights, :sort_title, :subject, :title, :geographic, :language] << @@prelim_elements
  ).flatten

  def self.required_elements
    @@required_elements
  end

  # Callbacks
  before_save :_defaults

  # Metadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Delegate attributes
  #   Provenance
  has_attributes :suppressed, :datastream => 'provMetadata', multiple: false
  has_attributes :passed_qc, :datastream => 'provMetadata', multiple: false
  # Descriptive
  # See https://github.com/pulibrary/pul-store/wiki/LAE-Descriptive-Elements
  has_attributes :alternative_title, :datastream => 'descMetadata', multiple: true
  has_attributes :extent, :datastream => 'descMetadata', multiple: false
  has_attributes :rights, :datastream => 'descMetadata', multiple: false
  has_attributes :series, :datastream => 'descMetadata', multiple: true
  has_attributes :description, :datastream => 'descMetadata', multiple: false
  has_attributes :publisher, :datastream => 'descMetadata', multiple: true

  # TODO: https://github.com/projecthydra/questioning_authority
  # Dropdown: https://github.com/curationexperts/tufts/blob/5856e409d743fbc2e6fc026274972f5e10d4fb4e/app/helpers/contribute_helper.rb#L10
  # Long-name: https://github.com/curationexperts/tufts/blob/276bdfe1ca3e2d465f6067a0dcc784bcac606efb/app/models/forms/capstone_project.rb#L18
  has_attributes :subject, :datastream => 'descMetadata', multiple: true
  has_attributes :genre, :datastream => 'descMetadata', multiple: false
  has_attributes :language, :datastream => 'descMetadata', multiple: true
  has_attributes :geographic, :datastream => 'descMetadata', multiple: true


  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'
  has_many :pages, as: :page_container, property: :is_part_of, :class_name => 'PulStore::Page'

  # Validations
  # Would like to DRY-up the barcode validations and put them in PulStore::Lae::Provenance
  # but haven't been able to figure out how.
  validates_presence_of :barcode, message: "A barcode is required"

  validates_length_of :barcode, 
    is: 14,
    message: "Barcode must be 14 characters long"

  validates_format_of :barcode, 
    with: /\A32101/, 
    message: "Barcode must start with '32101'"

  validate :validate_barcode

  # TODO: needs a format validation
  # THESE NEED CONDITIONS...or do we let the workflow states handle them or maybe only when in_production?
  # validates_presence_of :date_created, message: "A date is required"
  # validates_presence_of :subject, message: "At least one subject is required"
  # validates_presence_of :genre, message: "A genre term is required"
  # validates_presence_of :geographic, message: "At least one country is required"
  # validates_presence_of :extent, message: "Extent is required"
  # validates_presence_of :language, message: "At least one language term is required"
  # validates_presence_of :rights, message: "A rights statement is required"
  


  def suppressed?
    self.suppressed = false if self.suppressed.blank?
    ["true", 1, true].include? self.suppressed # Not cool. We want an actual boolean!
  end

  def passed_qc?
    self.passed_qc = false if self.passed_qc.blank?
    ["true", 1, true].include? self.passed_qc
  end

  def needs_qc?
    self.has_core_metadata? && 
    !self.passed_qc? #&&
    #!pages.blank? && 
    # && self.pages.all? { |p| p.valid? }
  end

  def has_prelim_metadata?
    @@prelim_elements.all? { |e| !self.send(e).blank? }
  end

  def has_core_metadata?
    @@required_elements.all? { |e| !self.send(e).blank? }
  end

  def in_production?
    false
    #all([#needs_qc?, passed_qc?, !suppress?])
  end



  protected
  def _defaults
    self.suppressed = self.suppressed?
    self.passed_qc = self.passed_qc?
    self.state = self._infer_state
    nil
  end

  def _infer_state
    # See https://github.com/pulibrary/pul-store/wiki/LAE-Workflow-and-&quot;States&quot;#folder-states
    # These labels should go in a config, eventually
    if error?
      "Error"
    elsif suppressed?
      "Suppressed"
    else
      if in_production?
        "Production"
      elsif needs_qc?
        "Needs QC"
      elsif has_core_metadata?
        "Has Core Metadata"
      elsif has_prelim_metadata?
        "Has Prelim. Metadata"
      else
        "New"
      end
    end
  end

end
