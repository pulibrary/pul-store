require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')
class PulStore::Lae::Folder < PulStore::Item
  include PulStore::Validations
  include PulStore::Lae::Provenance

  @@prelim_elements = [:barcode, :extent, :genre]
  def self.prelim_elements
    @@prelim_elements
  end

  @@required_elements = (
    [:date_created, :rights, :sort_title, :subject, :title, :geographic, 
      :language] << @@prelim_elements).flatten

  def self.required_elements
    @@required_elements
  end

  # Callbacks
  before_save :_defaults

  # Metadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Delegate attributes
  #   Provenance
  has_attributes :suppressed, :passed_qc, 
    :datastream => 'provMetadata', multiple: false

  # Descriptive
  # See https://github.com/pulibrary/pul-store/wiki/LAE-Descriptive-Elements
  has_attributes :alternative_title, :series, :publisher,
    :datastream => 'descMetadata', multiple: true

  has_attributes :extent, :rights, :description,
    :datastream => 'descMetadata', multiple: false

  # TODO: https://github.com/projecthydra/questioning_authority
  # Dropdown: https://github.com/curationexperts/tufts/blob/5856e409d743fbc2e6fc026274972f5e10d4fb4e/app/helpers/contribute_helper.rb#L10
  # Long-name: https://github.com/curationexperts/tufts/blob/276bdfe1ca3e2d465f6067a0dcc784bcac606efb/app/models/forms/capstone_project.rb#L18
  has_attributes :subject, :datastream => 'descMetadata', multiple: true
  has_attributes :genre, :datastream => 'descMetadata', multiple: false
  has_attributes :language, :datastream => 'descMetadata', multiple: true
  has_attributes :geographic, :datastream => 'descMetadata', multiple: true



  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'
  has_many :pages, property: :is_part_of, :class_name => 'PulStore::Page'

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
  validate :validate_barcode_uniqueness, on: :create

  validates_presence_of @@required_elements, if: :passed_qc?
  validates_presence_of :pages, if: :passed_qc?

  def suppressed?
    self.suppressed = false if self.suppressed.blank?
    ["true", 1, true].include? self.suppressed # Not cool. We want an actual boolean!
  end

  def passed_qc?
    self.passed_qc = false if self.passed_qc.blank?
    ["true", 1, true].include? self.passed_qc
  end

  def needs_qc?
    self.has_core_metadata? && !self.passed_qc? && !pages.blank? && self.pages.all? { |p| p.valid? }
  end

  def has_prelim_metadata?
    @@prelim_elements.all? { |e| !self.send(e).blank? }
  end

  def has_core_metadata?
    @@required_elements.all? { |e| !self.send(e).blank? }
  end

  def in_production?
    self.passed_qc? && !(self.suppressed? || self.error?)
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
        "In Production"
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
