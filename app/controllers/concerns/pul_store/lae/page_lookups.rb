module PulStore::Lae::PageLookups
  extend ActiveSupport::Concern
  included do

    def get_pages_by_folder(folder_id)
      solr = RSolr.connect(Blacklight.solr_config)
      # FIXME Get a default Where is the page sequence stored in index for this object?
      solr_response = solr.get 'select', :params => {:q => "is_part_of_ssim:info:fedora/#{folder_id}", :start => 0, :rows => 400, :wt => :ruby, :index => true }
      solr_response['response']['docs']
    end

  end
end