module PulStore::Lae::Provenance
  extend ActiveSupport::Concern

  PROJECT = PulStore::Project.where(desc_metadata__identifier_tesim: 'lae').first

  included do
    before_save { self.apply_timestamps } 
    
    has_attributes :barcode, :datastream => 'provMetadata', multiple: false
    has_attributes :error_note, :datastream => 'provMetadata', multiple: false
    has_attributes :workflow_state, :datastream => 'provMetadata', multiple: false
    # TODO: consider events, of which date_modified would be an attribute/property.
  end

  def error?
    !self.error_note.blank?
  end

  module ClassMethods
  end

end
