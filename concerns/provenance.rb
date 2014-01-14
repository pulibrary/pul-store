module PulStore::Lae::Provenance
  extend ActiveSupport::Concern

  included do
    has_attributes :barcode, :datastream => 'provMetadata', multiple: false
    has_attributes :error_note, :datastream => 'provMetadata', multiple: false
    has_attributes :state, :datastream => 'provMetadata', multiple: false
  end

  def error?
    self.error_note.blank?
  end

  module ClassMethods
  end

end
