module PulStore::Lae::Permissions
  extend ActiveSupport::Concern

  included do

    before_save { self.apply_default_permissions }
  end

  def apply_default_permissions
    if self.permissions.blank?
      self.edit_groups = ["all_project_writers", "lae_project_writers"]
      self.read_groups = ["all_project_readers", "lae_project_readers"]
      self.discover_groups = ["all_project_discover", "lae_project_discover"]
    end
    nil
  end

  module ClassMethods
  end

end
