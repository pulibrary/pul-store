class PulStore::Lae::Folder < PulStore::Item
  include PulStore::Validations
  include PulStore::Lae::Provenance
  include PulStore::Lae::Permissions

  # Class Constants
  @@prelim_elements = [:barcode, :genre]
  def self.prelim_elements
    @@prelim_elements
  end

  @@required_elements = (
    [:date_created, :rights, :sort_title, :subject, :title, :geographic,
      :language] << @@prelim_elements).flatten
  def self.required_elements
    @@required_elements
  end

  @@extent_elements = [:width_in_cm, :height_in_cm, :page_count]
  # These are a little difficult because
  # (width_in_cm AND height_in_cm) OR page_count
  # is required. See #has_extent?
  def self.extent_elements
    @@extent_elements
  end


  # Callbacks
  before_save :set_defaults
  before_validation :set_project

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

  has_attributes :height_in_cm, :width_in_cm, :page_count, :rights,
    :description,
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
  validates_presence_of @@prelim_elements

  validates_length_of :barcode,
    is: 14,
    message: "Barcode must be 14 characters long"

  validates_format_of :barcode,
    with: /\A32101/,
    message: "Barcode must start with '32101'"

  validate :validate_barcode

  validate :validate_barcode_uniqueness, on: :create
  validate :validate_barcode_uniqueness_on_update, on: :update

  validates_presence_of @@required_elements,
    if: :passed_qc?

  validate :validate_lae_folder_extent

  validates_presence_of :pages,
    if: :passed_qc?

  validates_presence_of :width_in_cm, :height_in_cm,
    if: "self.page_count.blank?"

  validates_numericality_of :width_in_cm, :height_in_cm,
    allow_nil: true, greater_than: 0, 
    unless: "self.width_in_cm.blank? && self.height_in_cm.blank?"

  validates_presence_of :page_count,
    if: "self.width_in_cm.blank? && self.height_in_cm.blank?"

  validates_numericality_of :page_count,
    only_integer: true, allow_nil: true, greater_than: 0, 
    unless: "self.page_count.blank?"


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
    self.has_extent? && @@prelim_elements.all? { |e| !self.send(e).blank? }
  end

  def has_core_metadata?
    self.has_extent? && @@required_elements.all? { |e| !self.send(e).blank? }
  end

  def in_production?
    self.passed_qc? && !(self.suppressed? || self.error?)
  end

  def has_extent?
    (!self.width_in_cm.blank? && !self.height_in_cm.blank?) || !self.page_count.blank?
  end

  def terms_for_editing
    [:barcode, :title, :alternative_title, :sort_title, :series, :publisher, :genre,
      :subject, :geographic, :language, :height_in_cm,
      :width_in_cm, :page_count, :date_created, :rights]
  end

  protected

  def set_project
    self.project ||= PulStore::Lae::Provenance::PROJECT
  end

  def set_defaults
    self.suppressed = self.suppressed?
    self.passed_qc = self.passed_qc?
    self.workflow_state = self.infer_state
    self.rights ||= PUL_STORE_CONFIG['lae_rights_boilerplate']
    nil
  end


  def infer_state
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
      # else
      #   "New"
      end
    end
  end

end
