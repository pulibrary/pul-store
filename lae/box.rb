require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')

class PulStore::Lae::Box < ActiveFedora::Base
  include Timestamp
  include Validations

  # Callbacks
  before_save :_defaults

  # Metadata
  has_metadata 'provMetadata', type: ProvRdfMetadata

  # Delegate attributes
  has_attributes :full, :datastream => 'provMetadata', multiple: false
  has_attributes :tracking_number, :datastream => 'provMetadata', multiple: false
  has_attributes :error_note, :datastream => 'provMetadata', multiple: false
  has_attributes :barcode, :datastream => 'provMetadata', multiple: false
  has_attributes :state, :datastream => 'provMetadata', multiple: false
  # For dates, UI should let a bool through and then set the date (DateTime.now.utc)
  has_attributes :shipped_date, :datastream => 'provMetadata', multiple: false
  has_attributes :received_date, :datastream => 'provMetadata', multiple: false

  # Associations
  has_many :folders, property: :in_box, :class_name => 'PulStore::Lae::Folder'
  # has_one hard_drive

  # Validations
  validates_presence_of :barcode, 
    message: "A barcode is required"

  validates_length_of :barcode, 
    is: 14,
    message: "Barcode must be 14 characters long"

  validates_format_of :barcode, 
    with: /\A32101/, 
    message: "Barcode must start with '32101'"

  validate :validate_barcode

  validates_presence_of :shipped_date, 
    message: "A shipped date is required in order for something to be received", 
    if: :received_date?

  validates_presence_of :shipped_date, 
    message: "A shipped date is required in order for there to be a tracking number", 
    if: :tracking_number

  validates_presence_of :tracking_number, 
    message: "A tracking number can only be supplied is the box is marked 'Shipped'",
    if: :shipped?

  validates_numericality_of :received_date,
    greater_than: :shipped_date, 
    message: "Received date must be after shipped date.",
    if: :received?

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
    self.ready_to_ship? && self.shipped_date? 
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

  def error?
    self.error_note.blank?
  end

  # TODO: state tests, once we have enough of Folder. We'll probably want a factory at that point
  # TODO: hard_drive tests, once we have enough of HardDrive


  protected

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
      elsif self._shipped?
        "Shipped"
      elsif self._ready_to_ship?
        "Ready to Ship"
      else
        "New"
      end
    end
  end

  def _defaults
    self.full = self.full?
    self.state = self._infer_state
    nil
  end



end


