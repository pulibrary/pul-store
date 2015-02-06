module PulStore::Lae::PageLookups
  extend ActiveSupport::Concern
  included do

    def get_pages_by_folder(folder_id)
      #solr = RSolr.connect(Blacklight.solr_config)
      # FIXME Get a default Where is the page sequence stored in index for this object?
      # sort by physical_number/sort_order
      q = "+is_part_of_ssim:\"info:fedora/#{folder_id}\" +active_fedora_model_ssi:\"PulStore::Page\""
      docs = ActiveFedora::SolrService.query(q, sort: 'desc_metadata__sort_order_isi asc', rows: 99999)
      docs
      # solr_response = solr.get 'select', :params => {:q => "is_part_of_ssim:info:fedora/#{folder_id} AND active_fedora_model_ssi:PulStore::Page", 
      #                                                 :start => 0, 
      #                                                 :rows => 400, 
      #                                                 :wt => :ruby, 
      #                                                 :index => true,
      #                                                 :sort => 'desc_metadata__sort_order_isi asc' }
      # solr_response['response']['docs']
    end

  end
end