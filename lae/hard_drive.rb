class PulStore::Lae::HardDrive < PulStore::Base
  include PulStore::Validations
  include PulStore::Lae::Provenance
  include PulStore::Lae::Permissions

  @remove_box = false
  def remove_box
    @remove_box
  end
  def remove_box=(value)
    @remove_box = ["1", true].include? value
  end

  before_save :set_state
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
  validate :validate_barcode_uniqueness, on: :create

  validates_presence_of :box, unless: :remove_box,
    message: "does not exist. Check 'Remove Box' if you meant to disassociate the box from this drive."
  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'


  protected

  def set_state
    unless self.box.blank?
      self.state = self.box.state
    else
      self.state = "Available"
    end
    nil
  end
end
