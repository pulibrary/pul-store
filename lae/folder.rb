require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')

class PulStore::Lae::Folder < PulStore::Item
  include Timestamp
  include Validations

    # Metadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Delegate attributes
  #   Provenance
  has_attributes :barcode, :datastream => 'provMetadata', multiple: false
  # error_note
  # suppress?
  # passed_qc? 
  # state
  #   Descriptive

  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'
# has_many pages

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


  def has_prelim_metadata?
    # PLACEHOLDER
    true
  end

  def in_production?
    # PLACEHOLDER
    true
  end

end
