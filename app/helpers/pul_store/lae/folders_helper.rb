module PulStore::Lae::FoldersHelper

  # Based on
  # def link_to_document(doc, opts={:label=>nil, :counter => nil})
  #   opts[:label] ||= blacklight_config.index.show_link.to_sym
  #   label = render_document_index_label doc, opts
  #   link_to label, doc, search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  # end


  def link_to_lae_folder(doc, opts={label: nil, counter: nil})
    label = lae_folder_title(doc)
    url = [lae_folders_path, doc[:id]].join '/'
    link_to(label, url)
    #search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  end

  def lae_folder_created_datetime(doc)
    PulStore::Lae::FoldersHelper.style_date(doc[:prov_metadata__date_uploaded_dtsi])
  end

  def lae_folder_last_modified_datetime(doc)
    doc[:prov_metadata__date_modified_ssi]
  end

  def lae_folder_barcode(doc)
    field = doc['prov_metadata__barcode_tesi']
    field.is_a?(Array) ? field[0] : field
  end

  def lae_folder_state(doc)
    field = doc[:prov_metadata__workflow_state_tesim]
    field.is_a?(Array) ? field[0] : field
  end


  def lae_folder_title(doc)
    title = doc[:desc_metadata__title_tesim]
    title = title[0] if title.is_a?(Array)
    title = '[Title not yet supplied]' if title.blank?
    title
  end

  def lae_folder_date_uploaded(date)
    PulStore::Lae::FoldersHelper.style_date(date)
  end

  def lae_folder_get_box_number(box_id)
    box = PulStore::Lae::Box.find(box_id)
    box.physical_number
  end

  def lae_folder_image_list_path(folder_id)
    "/lae/folders/#{folder_id}/image_list"
  end

  #def lae_folder_path(folder_id)
  #  "/lae/folders/#{folder_id}"
  #end

  def lae_date_value_set(folder)
    
  end

  def lae_folder_thumbnail(doc) 
    #pages = PulStore::Lae::PageLookups::get_pages_by_folder(doc['id'])
    page = PulStore::Page.where(is_part_of_ssim: "info:fedora/#{doc['id']}").first
    #page.id
  end

  def lae_link_to_previous_document(doc)
    link_to "Prev", "/lae/folders/#{doc['id']}"
  end

  def lae_link_to_next_document(doc)
    link_to "Next", "/lae/folders/#{doc['id']}"
  end

  # @page - solr doc of a page object
  def id_label_for_page(page)
    ids_labels = []
    label = "#{page['desc_metadata__display_label_ssm']} #{page['desc_metadata__sort_order_isi']}"
    #id = strip_iiif_server_base_from_id(page['id'])
    pid = PulStore::ImageServerUtils::pid_to_iiif_id(page['id'])
    Rails.logger.info("pid to process is #{pid}")
    ids_labels << {'id' => "#{pid}.jp2", 'label' => label}
  end

  def strip_iiif_server_base_from_id(id)
    #escaped_id = pul_store_iiif_path(id)
    base_url = "http://libimages.princeton.edu/loris2/"
    id = id.gsub("#{base_url}", '')
    #Rails.logger.info("pid to process is #{id}")
    id = PulStore::ImageServerUtils::pid_to_iiif_id(id)
    id
    #PulStore::ImageServerUtils::pid_to_iiif_id(id)
  end

  private
  @offset = Time.now.gmt_offset
  def self.style_date str
    fmt = '%A, %e %B, %Y. %l:%M%P'
    (DateTime.parse(str) + @offset.seconds).strftime(fmt)
  end

end
