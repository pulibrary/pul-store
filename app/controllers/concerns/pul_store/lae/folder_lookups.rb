module PulStore::Lae::FolderLookups
  extend ActiveSupport::Concern
  included do

    def get_folders_by_box(box_id)
      fedora_prefix = "info:fedora/"
      PulStore::Lae::Folder.where(in_box_ssim: "#{fedora_prefix}#{box_id}").order('prov_metadata__physical_number_ssi asc')
    end

    def get_folder_list_by_box(box_id)
      solr = RSolr.connect(Blacklight.solr_config)
      solr_response = solr.get 'select', :params => {:q => "in_box_ssim:info:fedora/#{box_id}", :start => 0, :rows => 400, :wt => :ruby, :index => true, :sort => "prov_metadata__physical_number_ssi desc" }
      solr_response['response']['docs']
    end

  end
end