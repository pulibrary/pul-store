module PulStore::RecordsControllerBehavior
  extend ActiveSupport::Concern
  include RecordsControllerBehavior

  # You custom code
  included do
    load_and_authorize_resource only: [:edit, :update], instance_name: resource_instance_name

    rescue_from HydraEditor::InvalidType do
      render 'records/choose_type'
    end
    helper_method :resource
  end
end
