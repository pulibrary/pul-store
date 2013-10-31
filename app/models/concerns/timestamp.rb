module Timestamp
  extend ActiveSupport::Concern

  included do
    before_save { self.apply_timestamps } 

    delegate :date_uploaded, to: 'provMetadata', multiple: false
    delegate :date_modified, to: 'provMetadata', multiple: true
    # TODO: consider events, of which date_modified would be an attribute/property.
  end

  def apply_timestamps
    if [[], nil].any? { |v| self.date_uploaded == v }
      self.date_uploaded << DateTime.now.utc # << even though multiple: false
    end
    self.date_modified << DateTime.now.utc
  end

  module ClassMethods
  end

end
