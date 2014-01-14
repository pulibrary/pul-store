require Rails.root.join('app/models/pul_store/lib/active_fedora/pid')

class PulStore::Lae::Folder < PulStore::Item
  include Timestamp
  include Validations

    # Metadata
  has_metadata 'provMetadata', type: ProvRdfMetadata
  has_metadata 'descMetadata', type: PulStore::Lae::FolderRdfMetadata

  # Associations
  belongs_to :box, property: :in_box, :class_name => 'PulStore::Lae::Box'

  def has_prelim_metadata?
    # PLACEHOLDER
    true
  end

  def in_production?
    # PLACEHOLDER
    true
  end

end
