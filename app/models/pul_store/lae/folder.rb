class PulStore::Lae::Folder < PulStore::Item
  include PulStore::Validations
  include PulStore::Lae::Provenance
  include PulStore::Lae::Permissions
  include PulStore::Lae::Exportable

  # Class Constants
  @@prelim_elements = [:barcode, :genre]
  def self.prelim_elements
    @@prelim_elements
  end

  @@required_elements = ([:rights, :sort_title, :title, 
    :geographic_subject, :geographic_origin, :language, :subject, :category] << @@prelim_elements).flatten

  def self.required_elements
    @@required_elements
  end

  # These are a little difficult because
  # (width_in_cm AND height_in_cm) OR page_count
  # is required. See #has_extent?
  def self.extent_elements
    [:width_in_cm, :height_in_cm, :page_count]
  end

  # Similarly, we need date_created OR (earliest_created AND latest_created)
  def self.date_elements
    [:date_created, :earliest_created, :latest_created]
  end

  # Callbacks
  before_save :set_defaults
  before_validation :set_project

  # Metadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Delegate attributes
  #   Provenance
  has_attributes :suppressed, :passed_qc, :physical_number,
    :datastream => 'provMetadata', multiple: false

  # Descriptive
  # See https://github.com/pulibrary/pul-store/wiki/LAE-Descriptive-Elements
  has_attributes :alternative_title, :series, :publisher, :subject, :language, 
    :geographic_subject, :category,
    :datastream => 'descMetadata', multiple: true

  has_attributes :height_in_cm, :width_in_cm, :page_count, :rights,
    :description, :genre, :geographic_origin,
    :datastream => 'descMetadata', multiple: false

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

  validates_presence_of @@required_elements,
    if: :passed_qc?

  validate :required_arrays_elements_are_not_all_blank, if: :has_core_metadata?

  validates_presence_of :date_created, 
    unless: :has_earliest_and_latest?,
    if: :passed_qc?

  validates_presence_of [:earliest_created, :latest_created], 
    unless: :has_date_created?,
    if: :passed_qc?

  validates_format_of :date_created, 
    with: /\A[12]\d{3}\Z/,
    unless: :has_earliest_and_latest?,
    if: :passed_qc?

  validates_format_of [:earliest_created, :latest_created], 
    with: /\A[12]\d{3}\Z/,
    unless: :has_date_created?,
    if: :passed_qc?

  validate :earliest_date_before_latest
  validate :only_date_range_or_date

  validates_presence_of :physical_number

  validates_numericality_of :physical_number,
    only_integer: true, allow_nil: true, greater_than: 0

  # validates_each :category, :subject do |record, attr, val| 
  #   record.errors.add(attr, "Must not be Empty") if val =~ /\w+/
  # end

  def required_elements
    @@required_elements
  end

  def suppressed?
    self.suppressed = false if self.suppressed.blank?
    ["true", 1, true].include? self.suppressed # Not cool. We want an actual boolean!
  end

  def passed_qc?
    self.passed_qc = false if self.passed_qc.blank?
    ["true", 1, true].include?(self.passed_qc)
  end

  def needs_qc?
    self.has_core_metadata? && !self.passed_qc? && !pages.blank? && self.pages.all? { |p| p.valid? }
  end

  def has_prelim_metadata?
    self.has_extent? && @@prelim_elements.all?  { |e| 
      if self.send(e).kind_of?(Array)
        !self.send(e).all? { |member| member.blank? }
      else
        !self.send(e).blank?
      end
    }
  end

  def has_core_metadata?
    self.has_extent? && self.has_dates? && @@required_elements.all? { |e| 
      if self.send(e).kind_of?(Array)
        !self.send(e).all? { |member| member.blank? }
      else
        !self.send(e).blank?
      end
    }
  end

  def in_production?
    self.passed_qc? && !(self.suppressed? || self.error?)
  end

  def has_extent?
    (!self.width_in_cm.blank? && !self.height_in_cm.blank?) || !self.page_count.blank?
  end

  def terms_for_editing
    [:barcode, :title, :alternative_title, :sort_title, :series, :publisher, :genre,
      :subject, :geographic_origin, :geographic_subject, :language, :height_in_cm,
      :width_in_cm, :page_count, :date_created, :rights, :category]
  end

  def to_json(id)
    self.to_export.to_json
    
    # self.to_manifest
  end

  protected

  def set_project
    self.project ||= PulStore::Lae::Provenance::PROJECT
  end

  def set_defaults
    self.suppressed = self.suppressed?
    self.passed_qc = self.passed_qc?
    self.workflow_state = self.infer_state
    if !self.physical_number.blank? 
      self.physical_number = self.physical_number.to_i
    end
    if !self.page_count.blank? 
      self.page_count = self.page_count.to_i
    end
    if !self.height_in_cm.blank? 
      self.height_in_cm  = self.height_in_cm.to_i
    end
    if !self.width_in_cm.blank? 
      self.width_in_cm = self.width_in_cm.to_i
    end
    if !self.date_created.blank? 
      self.date_created = self.date_created.to_i
    end
    if !self.latest_created.blank? 
      self.latest_created = self.latest_created.to_i
    end
    if !self.earliest_created.blank? 
      self.earliest_created = self.earliest_created.to_i
    end
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
