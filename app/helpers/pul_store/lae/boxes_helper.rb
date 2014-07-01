module PulStore::Lae::BoxesHelper

  # Based on
  # def link_to_document(doc, opts={:label=>nil, :counter => nil})
  #   opts[:label] ||= blacklight_config.index.show_link.to_sym
  #   label = render_document_index_label doc, opts
  #   link_to label, doc, search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  # end


  def link_to_lae_box(doc, opts={label: nil, counter: nil})
    barcode_field = doc['prov_metadata__barcode_tesi']
    box_number = lae_box_number doc
    barcode ||= barcode_field if barcode_field.is_a? String
    barcode ||= barcode_field[0] if barcode_field.is_a? Array
    label ||= "Box #{box_number} - #{barcode}"
    url = [lae_boxes_path, doc[:id]].join '/'
    link_to(label, url)
    #search_session_params(opts[:counter]).merge(opts.reject { |k,v| [:label, :counter].include? k  })
  end

  def lae_box_created_datetime(doc)
    PulStore::Lae::BoxesHelper.style_date(doc[:prov_metadata__date_uploaded_dtsi])
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

  def lae_box_number(doc)
    field = doc[:prov_metadata__physical_number_isi]
    field.is_a?(Array) ? field[0] : field
  end

  ### FIXME - Confirm these do not do anything
  ### Add or Remove Folders to box Forms
  def link_to_remove_fields(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end

  def link_to_add_fields(name, f, association, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{ association }", :onsubmit => "return $(this.)validate();") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end

    link_to_function(name, "add_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", options)
  end
  #####################

  private
  @offset = Time.now.gmt_offset
  def self.style_date str
    fmt = '%A, %e %B, %Y. %l:%M%P'
    (DateTime.parse(str) + @offset.seconds).strftime(fmt)
  end

end
