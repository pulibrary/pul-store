module PulStore

  def self.use_relative_model_naming?
    true
  end

  class Base < ActiveFedora::Base
    include PulStore::Timestamp

    has_metadata 'provMetadata', type: PulStore::ProvRdfMetadata

    belongs_to :project, property: :is_part_of_project, :class_name => 'PulStore::Project'

    validates_presence_of :project, 
      :unless => "self.instance_of?(PulStore::Project)"
  end

end
