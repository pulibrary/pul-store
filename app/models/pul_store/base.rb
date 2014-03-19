require File.expand_path('../../../../lib/active_fedora/pid', __FILE__)

module PulStore

  def self.use_relative_model_naming?
    true
  end

  class Base < ActiveFedora::Base
    include PulStore::Timestamp
    include Hydra::AccessControls::Permissions

    before_destroy :check_for_children
    before_save :set_project_label

    has_metadata 'provMetadata', type: PulStore::ProvRdfMetadata

    belongs_to :project, property: :is_part_of_project, :class_name => 'PulStore::Project'

    # We want to be able to facet on this, so copy the project label here before 
    # save. Is there a better way?
    has_attributes :project_label, :datastream => 'provMetadata', multiple: false

    validates_presence_of :project, :unless => "self.instance_of?(PulStore::Project)"

    private
    def check_for_children
      unless self.class.child_association_names.all? {|a| self.send(a).empty? }
        msg = "Cannot delete #{self.pid} because dependent parts are associated with it"
        self.errors.add(:base, msg)
      end
      self.errors.empty?
    end

    def self.child_association_names
      associations = [:has_many, :has_one, :has_and_belongs_to_many]
      associations.map { |a| self.get_assocation_names(a) }.flatten
    end

    def self.get_assocation_names(association)
      self.reflections.select { |name,ref| 
        ref.macro == association
      }.map { |name,ref| 
        ref.name 
      }
    end

    def set_project_label
      unless self.instance_of?(PulStore::Project)
        self.project_label = self.project.label
      end
    end
  end

end
