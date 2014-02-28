module PulStore::Lae::BoxesHelper

  # Based on
  # def link_to_document(doc, opts={:label=>nil, :counter => nil})
  #   opts[:label] ||= blacklight_config.index.show_link.to_sym
  #   label = render_document_index_label doc, opts
  #   link_to label, doc, search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  # end
  

  def link_to_lae_box(doc, opts={label: nil, counter: nil})
    barcode_field = doc['prov_metadata__barcode_tesim']
    label ||= barcode_field if barcode_field.is_a? String
    label ||= barcode_field[0] if barcode_field.is_a? Array
    url = [lae_boxes_path, doc[:id]].join '/'
    link_to(label, url)
    #search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  end

  def lae_box_created_datetime(doc)
    # PulStore::Lae::BoxesHelper.style_date(doc[:prov_metadata__date_uploaded_ssi])
    doc[:prov_metadata__date_uploaded_ssi]
  end

  def lae_box_last_modified_datetime(doc)
    doc[:prov_metadata__date_modified_ssi]
  end

  def lae_box_shipped_datetime(doc)
    doc[:prov_metadata__shipped_date_ssi] || "n/a"
  end

  def lae_box_received_datetime(doc)
    doc[:prov_metadata__received_date_ssi] || "n/a"
  end

  def lae_box_state(doc)
    field = doc[:prov_metadata__workflow_state_tesim]
    field.is_a?(Array) ? field[0] : field
  end
  
  private
  @tz = Time.now.zone

  def self.style_date str
    fmt = '%A, %e %B, %Y. %l:%M%P'
    
    DateTime.parse(str).in_time_zone(@tz).strftime(fmt)

  end

end
