require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')

class PulStore::Lae::Folder < PulStore::Item
  include Timestamp
  include Validations
  include PulStore::Lae::Provenance

  # Callbacks
  before_save :_defaults

  # Metadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Delegate attributes
  #   Provenance
  has_attributes :suppressed, :datastream => 'provMetadata', multiple: false
  has_attributes :passed_qc, :datastream => 'provMetadata', multiple: false
  #   Descriptive

  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'
# has_many pages

  # Validations
  # Would like to DRY-up the barcode validations and put them in PulStore::Lae::Provenance
  # but haven't been able to figure out how.
  validates_presence_of :barcode, 
    message: "A barcode is required"

  validates_length_of :barcode, 
    is: 14,
    message: "Barcode must be 14 characters long"

  validates_format_of :barcode, 
    with: /\A32101/, 
    message: "Barcode must start with '32101'"

  validate :validate_barcode

  def suppressed?
    self.suppressed = false if self.suppressed.blank?
    ["true", 1, true].include? self.suppressed # Not cool. We want an actual boolean!
  end

  def passed_qc?
    self.passed_qc = false if self.passed_qc.blank?
    ["true", 1, true].include? self.passed_qc
  end

  def has_prelim_metadata?
    # PLACEHOLDER
    true
  end

  def in_production?
    # PLACEHOLDER
    true
  end

  protected
  def _defaults
    self.suppressed = self.suppressed?
    self.passed_qc = self.passed_qc?
    self.state = self._infer_state
    nil
  end

  def _infer_state
    "NOT YET IMPL"
    # See https://github.com/pulibrary/pul-store/wiki/LAE-Workflow-and-&quot;States&quot;#box-states
    # These labels should go in a config, eventually
    # if error?
    #   "Error"
    # else
    #   if self.all_folders_in_production?
    #     "All in Production"
    #   elsif self.received?
    #     "Received"
    #   elsif self._shipped?
    #     "Shipped"
    #   elsif self._ready_to_ship?
    #     "Ready to Ship"
    #   else
    #     "New"
    #   end
    # end
  end

end
