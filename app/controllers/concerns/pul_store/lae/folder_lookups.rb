module PulStore::Lae::FolderLookups
  extend ActiveSupport::Concern
  included do

    def get_folders_by_box(box_id)
      fedora_prefix = "info:fedora/"
      PulStore::Lae::Folder.where(in_box_ssim: "#{fedora_prefix}#{box_id}").order('prov_metadata__physical_number_ssi asc')
    end

    def get_folder_list_by_box(box_id)
      solr = RSolr.connect(Blacklight.solr_config)
      fields_to_return = 'prov_metadata__physical_number_ssi,prov_metadata__workflow_state_tesim,id,desc_metadata__title_tesim,desc_metadata__genre_tesim,prov_metadata__barcode_tesim'
      solr_response = solr.get 'select', :params => {:q => "in_box_ssim:info:fedora/#{box_id}", :fl => fields_to_return, :start => 0, :rows => 300, :wt => :ruby, :index => true }
      self.convert_solr_string_sort_int(solr_response['response']['docs'], 'prov_metadata__physical_number_ssi')
    end

    # folder folders string sort field treated as numeric is prov_metadata__physical_number_ssi
    # FIXME where should this generic helper be best located? 
    def convert_solr_string_sort_int(solr_doc_list, field_to_sort_as_int)
      solr_doc_list.sort {|doc1, doc2| doc2["#{field_to_sort_as_int}"].to_i <=> doc1["#{field_to_sort_as_int}"].to_i} 
    end

  end
end