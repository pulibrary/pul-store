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
    PulStore::Lae::FoldersHelper.style_date(doc[:prov_metadata__date_uploaded_ssi])
  end

  def lae_folder_last_modified_datetime(doc)
    doc[:prov_metadata__date_modified_ssi]
  end

  def lae_folder_barcode(doc)
    field = doc['prov_metadata__barcode_tesim']
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

  private
  @tz = Time.now.zone
  @offset = Time.now.gmt_offset
  def self.style_date str
    fmt = '%A, %e %B, %Y. %l:%M%P'
    #DateTime.parse(str).in_time_zone(@tz).strftime(fmt)
    (DateTime.parse(str) + @offset.seconds).strftime(fmt)
  end

end
