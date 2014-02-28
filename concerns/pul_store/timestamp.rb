module PulStore::Timestamp
  extend ActiveSupport::Concern

  included do
    before_save { self.apply_timestamps } 
    
    has_attributes :date_uploaded, :datastream => 'provMetadata', multiple: false
    has_attributes :date_modified, :datastream => 'provMetadata', multiple: true
    # TODO: consider events, of which date_modified would be an attribute/property.
  end

  def apply_timestamps
    if self.date_uploaded.nil?
      # self.date_uploaded = DateTime.now.utc
      self.date_uploaded = DateTime.now.utc
    end
    self.date_modified << DateTime.now.utc
  end

  module ClassMethods
  end

end
