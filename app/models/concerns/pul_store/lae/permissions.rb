module PulStore::Lae::Permissions
  extend ActiveSupport::Concern

  included do

    before_save { self.apply_default_permissions }
  end

  def apply_default_permissions
    if self.permissions.blank?
      self.discover_groups = ["all_project_discover", "lae_project_discover"]
      self.read_groups = ["all_project_readers", "lae_project_readers"]
      self.edit_groups = ["all_project_writers", "lae_project_writers"]
    end

    #### if a box && shareable set add 'public' to read_groups
    if !self.permissions.blank?
      if self.class == PulStore::Lae::Box && self.shareable?
        self.discover_groups = ["all_project_discover", "lae_project_discover", "public"]
        self.read_groups = ["all_project_readers", "lae_project_readers", "public"]
      else
        self.discover_groups = ["all_project_discover", "lae_project_discover"]
        self.read_groups = ["all_project_readers", "lae_project_readers"]
      end
    end

    nil
  end

  module ClassMethods
  end

end
