class PulStore::Lae::Box < PulStore::Base
  include PulStore::Validations
  include PulStore::Lae::Provenance
  include PulStore::Lae::Permissions

  # Callbacks
  before_save :_defaults
  before_validation do
    self.physical_location = PUL_STORE_CONFIG['lae_recap_code'] if self.physical_location.blank?
    self.project ||= PulStore::Lae::Provenance::PROJECT   
    self.physical_number ||= PulStore::Lae::BoxCounter.mint 
  end

  # Delegate attributes
  has_attributes :full, :physical_location, :tracking_number, :physical_number,
    :datastream => 'provMetadata', multiple: false
  # For dates, UI should let a bool through and then set the date (Date.current)
  has_attributes :shipped_date, :received_date,
    :datastream => 'provMetadata', multiple: false

  # Associations
  belongs_to :project, property: :is_part_of_project, :class_name => 'PulStore::Project'
  has_many :folders, property: :in_box, :class_name => 'PulStore::Lae::Folder'
  has_many :hard_drives, property: :in_box, :class_name => 'PulStore::Lae::HardDrive'

  # Accepts Attributes for
  accepts_nested_attributes_for :folders, reject_if: proc { |attributes| attributes['barcode'].blank? }
  # Validations
  validates_presence_of :barcode,
    message: "A barcode is required"

  validates_length_of :barcode,
    is: 14,
    message: "Barcode must be 14 characters long"

  validates_format_of :barcode,
    with: /\A32101/,
    message: "Barcode must start with '32101'"

  validates_presence_of :shipped_date,
    message: "A shipped date is required in order for something to be received",
    if: :received_date?

  validates_presence_of :shipped_date,
    message: "A shipped date is required in order for there to be a tracking number",
    if: :tracking_number

  validates_presence_of :tracking_number,
    message: "A tracking number can only be supplied is the box is marked 'Shipped'",
    if: :shipped?

  validate :validate_barcode
  validate :validate_barcode_uniqueness, on: :create
  validate :validate_barcode_uniqueness_on_update, on: :update
  validate :validate_shipped_before_received

  validates_presence_of :physical_location
  validates_presence_of :project

  def full?
    self.full = false if self.full.nil?
    ["true", 1, true].include? self.full # Not cool. We want an actual boolean!
  end

  def ready_to_ship?
    self.full? && self.folders.all? { |f| f.has_prelim_metadata? }
  end

  def shipped_date?
    !self.shipped_date.blank?
  end

  def shipped?
    self.ready_to_ship? && self.shipped_date? && !self.tracking_number.blank?
  end

  def received_date?
    !self.received_date.blank?
  end

  def received?
    self.shipped? && self.received_date?
  end

  def all_folders_in_production?
    self.received? && self.folders.all? { |f| f.in_production? }
  end

  # TODO: hard_drive tests, once we have enough of HardDrive


  protected

  def _defaults
    self.full = self.full?
    self.workflow_state = self._infer_state
    nil
  end

  def _infer_state
    # See https://github.com/pulibrary/pul-store/wiki/LAE-Workflow-and-&quot;States&quot;#box-states
    # These labels should go in a config, eventually
    if error?
      "Error"
    else
      if self.all_folders_in_production?
        "All in Production"
      elsif self.received?
        "Received"
      elsif self.shipped?
        "Shipped"
      elsif self.ready_to_ship?
        "Ready to Ship"
      else
        "New"
      end
    end
  end

end

