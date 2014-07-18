class Ability
  include Hydra::Ability

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group

    if user_groups.include? ['all_project_writers']
       can [:create], PulStore::Base
       can [:create], PulStore::Lae::Box
       can [:create], PulStore::Lae::Folder
       can [:create], Pulstore::Lae::HardDrive
    end

    if user_groups.include? ['lae_project_writers']
       can [:create], PulStore::Lae::Box
       can [:create], PulStore::Lae::Folder
       can [:create], Pulstore::Lae::HardDrive
    end 

    if user_groups.include? ['all_project_writers']
       can [:destroy], PulStore::Base
    end

    if user_groups.include? ['lae_project_readers', 'all_project_readers' ]
      can [:show], PulStore::Base
    end
  end
end
