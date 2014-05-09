module PulStore::Lae::BoxLookups
  extend ActiveSupport::Concern
  included do

    def get_box_by_id(box_id)
      solr = RSolr.connect(Blacklight.solr_config)
      # FIXME Get a default Where is the page sequence stored in index for this object?
      solr_response = solr.get 'select', :params => {:q => "{box_id}", :start => 0, :rows => 400, :wt => :ruby, :index => true }
      solr_response['response']['docs']
    end

  end
end