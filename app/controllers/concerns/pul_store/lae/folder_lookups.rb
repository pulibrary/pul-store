module PulStore::Lae::FolderLookups
  extend ActiveSupport::Concern
  included do

    def get_folders_by_box(box_id)
      fedora_prefix = "info:fedora/"
      PulStore::Lae::Folder.where(in_box_ssim: "#{fedora_prefix}#{box_id}").order('prov_metadata__physical_number_ssi asc')
    end

    def get_folder_list_by_box(box_id, docs = 20)
      solr = RSolr.connect(Blacklight.solr_config)
      fields_to_return = 'prov_metadata__physical_number_isi,prov_metadata__workflow_state_tesim,id,desc_metadata__title_tesim,desc_metadata__genre_tesim,prov_metadata__barcode_tesi'
      solr_response = solr.get 'select', :params => {:q => "in_box_ssim:info:fedora/#{box_id}", 
                                                     :fl => fields_to_return, 
                                                     :start => 0, 
                                                     :rows => docs, 
                                                     :wt => :ruby, 
                                                     :index => true,
                                                     :sort => "prov_metadata__physical_number_isi desc" }
      solr_response['response']['docs']
    end

  end
end
