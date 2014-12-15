
require File.expand_path('../../../../../../lib/rdf/pul_store_terms', __FILE__)
require 'rdf'
require 'rdf/turtle'
require 'nokogiri'
require 'iiif/presentation'
require 'active_support/ordered_hash'

module PulStore::Lae::Exportable
  extend ActiveSupport::Concern
  included do
    PREFIXES ||= {
      dc: RDF::DC.to_uri,
      dctype: RDF::URI.new('http://purl.org/dc/dcmitype/'),
      foaf: RDF::FOAF.to_uri,
      geonames:  RDF::URI.new('http://sws.geonames.org/'),
      lae: RDF::URI.new('http://lae.princeton.edu/'),
      lang: RDF::URI.new('http://id.loc.gov/vocabulary/iso639-2/'),
      lcco: RDF::URI.new('http://id.loc.gov/vocabulary/countries/'),
      lcga: RDF::URI.new('http://id.loc.gov/vocabulary/geographicAreas/'),
      lcsh: RDF::URI.new('http://id.loc.gov/authorities/subjects/'),
      marcrel: RDF::URI.new('http://id.loc.gov/vocabulary/relators/'),
      owl: RDF::OWL.to_uri,
      pulterms: RDF::URI.new('http://princeton.edu/pulstore/terms/'),
      rdf: RDF.to_uri,
      rdfs: RDF::RDFS.to_uri,
      tgm: RDF::URI.new('http://id.loc.gov/vocabulary/graphicMaterials/'),
      unit: RDF::URI.new('http://sweet.jpl.nasa.gov/2.3/reprSciUnits.owl'),
      xsd: RDF::XSD.to_uri
    }
    CM_TYPE ||= RDF::URI.new('http://sweet.jpl.nasa.gov/2.3/reprSciUnits.owl#centimeter')
    LANG_LOOKUP ||= {
      'por' => :pt,
      'spa' => :es,
      'eng' => :en
    }


    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    def to_export(opts={})
      if self.class == PulStore::Lae::Folder
        return self.to_folder_export_hash(opts)
      elsif self.class == PulStore::Lae::Box
        folders = []
        self.folders.each do |f|
          folder_h = f.to_folder_export_hash(opts)
          folders << folder_h unless folder_h.nil?
        end
        return folders
      end
    end

    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    def to_yaml(opts={})
      self.to_export(opts).to_yaml
    end

    # Return Solr-flavored XML; intended for indexing in external systems.
    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    def to_solr_xml(opts={})
      blanks = ['', [], ['']]
      atomic_fields_we_want = %w{
        id barcode date_uploaded date_modified physical_number project_label
        date_created earliest_created latest_created sort_title height_in_cm
        width_in_cm page_count rights
      }
      array_fields_we_want = %w{
        contributor creator title alternative_title description publisher
        series category
      }
      #k, sub_k (k = key for field (may point to an array), sub_k = key for hash)
      hash_values_we_want = {
        'geographic_origin' => %w{ label iso_3166_2_code gac_code geoname_id },
        'geographic_subject' => %w{ label iso_3166_2_code gac_code geoname_id },
        'subject' => %w{ label },
        'genre' => %w{ pul_label },
        'language' => %w{ label },
        'box' => %w{ barcode physical_location physical_number },
        'project' =>  %w{ label }
      }
      export_hashes = self.to_export(opts)
      export_hashes = [ export_hashes ] unless export_hashes.kind_of?(Array)
      bob = Nokogiri::XML::Builder.new do |xml|
        xml.send(:add) do
          export_hashes.each do |export_hash|
            xml.send(:doc_) do
              export_hash.each do |k,v|
                if blanks.include?(v)
                  # skip it. blank? doesn't quite work because of ['']
                elsif atomic_fields_we_want.include?(k)
                  if k == 'id'
                    xml.send(:field, v.split(':').last, name: k)
                    xml.send(:field, v, name: 'pulstore_pid')
                  elsif k == 'title'
                    xml.send(:field, v.first, name: 'title_display')
                  elsif k == 'date_created'
                    unless blanks.include?(v)
                      xml.send(:field, v, name: 'date_display')
                      xml.send(:field, v, name: k)
                    end
                  elsif k == 'earliest_created'
                    display = "#{v}-#{export_hash['latest_created']}"
                    unless blanks.include?(v)
                      xml.send(:field, display, name: 'date_display') 
                      xml.send(:field, v, name: k)
                    end
                  else
                    xml.send(:field, v, name: k) unless blanks.include?(v)
                  end
                elsif array_fields_we_want.include?(k)
                  v.each do |member|
                    xml.send(:field, member, name: k) unless blanks.include?(member)
                  end
                elsif hash_values_we_want.has_key?(k)
                  if v.kind_of?(Array) # array of hashes
                    v.each do |hsh|
                      hash_values_we_want[k].each do |sub_k|
                        xml.send(:field, hsh[sub_k], name: "#{k}_#{sub_k}") unless blanks.include?(v)
                      end
                    end
                  else # v is a hash
                    hash_values_we_want[k].each do |sub_k|
                      xml.send(:field, v[sub_k], name: "#{k}_#{sub_k}") unless blanks.include?(v)
                    end
                  end
                end
              end
              if export_hash['active_fedora_model_ssi'] == 'PulStore::Lae::Folder'
                ttl = to_ttl(data: export_hash)
                xml.send(:field, ttl, name: :ttl)
                manifest = to_manifest(data: export_hash)
                xml.send(:field, manifest, name: :manifest)
                thumb = PulStore::ImageServerUtils.build_iiif_base_uri(export_hash['pages'].first['id'])
                xml.send(:field, thumb, name: :thumbnail_base)
              end

            end
          end
        end
      end
      return bob.to_xml
    end

    # opts:
    #   prod_only: only return the hash if state it "In Production". Default: true
    #   data: the export hash, in case you already have it
    def to_ttl(opts={})
      self.to_graph(opts).dump(:turtle, prefixes: PREFIXES)
    end

    # opts:
    #   data: (REQUIRED) the export hash
    def to_manifest(opts={})
      # fetch seems to be calling #to_export even if we pass :data in...
      data = opts.has_key?(:data) ? opts[:data] : self.to_export(opts)
      uri = "#{PREFIXES[:lae].to_s}catalog/#{self.id}"
      manifest = IIIF::Presentation::Manifest.new('@id' => uri)
      manifest.label = data['title'][0]
      manifest.viewing_hint = 'individuals'
      manifest.metadata = self.class.to_iiif_metadata(data)
      sequence = IIIF::Presentation::Sequence.new
      data.fetch('pages', []).sort_by { |p| p['sort_order'] }.each do |p|
        sequence.canvases << self.canvas_from_page_hash(p)
      end
      manifest.sequences << sequence
      unless manifest.sequences.first.canvases.empty?
        thumb = manifest.sequences.first.canvases.first.images.first.resource['@id']
        manifest.insert_after(existing_key: 'label', new_key: 'thumbnail', value: thumb)
      end
      manifest.to_json
    rescue Exception => e
      logger.error(data[:id])
      raise e
    end



    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    #   data: the export hash, in case you already have it
    def to_graph(opts={})
      # fetch seems to be calling #to_export even if we pass :data in...
      data = opts.has_key?(:data) ? opts[:data] : self.to_export(opts)
      graph = RDF::Graph.new
      this = PREFIXES[:lae].join(data['id'].sub(/puls:/, ''))
      # type
      type = data['active_fedora_model_ssi'].split('::').last
      if type == 'Folder'
        type_uri = PREFIXES[:lae].join(type)
        graph << [this, RDF.type, type_uri]
        graph << [type_uri, RDF::RDFS.subClassOf, PREFIXES[:dctype].join('Text')]
      end
      # Alt
      this_in_repo = RDF::URI.new("http://pulstore.princeton.edu/lae/folders/#{data['id']}")
      graph << [this, RDF::OWL.sameAs, this_in_repo]


      lang_code = LANG_LOOKUP[data['language'][0]['code']]

      # title
      graph << [this, RDF::DC.title, RDF::Literal.new(data['title'][0], language: lang_code)]

      # alternative title
      if data.has_key?('alternative_title')
        data.fetch('alternative_title', []).each do |at|
          graph << [this, RDF::DC.alternative, RDF::Literal.new(at, language: lang_code)] unless at.blank?
        end
      end

      # dc literals..any property in our data that has the same name as the dc term
      ['creator', 'contributor', 'publisher'].each do |p|
        data.fetch(p, []).each do |v|
          graph << [this, RDF::DC.send(p), RDF::Literal.new(v)] unless v.blank?
        end
      end

      # ...except description and rights  which we know are always in English
      data.fetch('description', []).each do |d|
        unless d.blank?
          graph << [this, RDF::DC.description, RDF::Literal.new(d, language: :en)]
        end
      end

      unless data.fetch('rights', '').blank?
        graph << [this, RDF::DC.rights, RDF::Literal.new(data['rights'], language: :en)]
      end

      # dc uris
      ['subject','language'].each do |p|
        data.fetch(p, []).each do |v|
          if v['uri'].blank?
            graph << [this, RDF::DC.send(p), RDF::Literal.new(v['label'], language: :en)]
          else
            graph << [this, RDF::DC.send(p), RDF::URI.new(v['uri'])]
          end
        end
      end

      # dates
      unless data['date_created'].blank?
        dc = RDF::Literal.new(data['date_created'], datatype: RDF::XSD.gYear)
        graph << [this, RDF::DC.created, dc]
      end

      unless data['earliest_created'].blank?
        ed = RDF::Literal.new(data['earliest_created'], datatype: RDF::XSD.gYear)
        graph << [this, RDF::PulStoreTerms.earliestCreated, ed]
      end

      unless data['latest_created'].blank?
        ld = RDF::Literal.new(data['latest_created'], datatype: RDF::XSD.gYear)
        graph << [this, RDF::PulStoreTerms.latestCreated, ld]
      end

      # genre
      data.fetch('genre', []).each do |g|
        graph << [this, RDF::DC.format, RDF::URI.new(g['uri'])] unless g['uri'].blank?
      end

      # geographic subject
      data.fetch('geographic_subject', []).each do |gs|
        if gs.has_key?'geoname_id'
          graph << [this, RDF::DC.coverage, PREFIXES[:geonames].join(gs['geoname_id'])]
        elsif gs.has_key?'uri'
          graph << [this, RDF::DC.coverage, RDF::URI.new(gs['uri'])]
        end
      end

      # geographic origin
      origin = data['geographic_origin']['uri']
      graph << [this, PREFIXES[:marcrel].join('mfp'), RDF::URI.new(origin)] unless origin.blank?

      # extent stuff
      unless [nil, ''].include? data['height_in_cm']
        h = RDF::Literal.new(data['height_in_cm'], datatype: CM_TYPE)
        graph << [this, RDF::PulStoreTerms.height, h]
        graph << [RDF::PulStoreTerms.height, RDF::RDFS.subPropertyOf, RDF::DC.extent]
      end
      unless [nil, ''].include? data['width_in_cm']
        w = RDF::Literal.new(data['width_in_cm'], datatype: CM_TYPE)
        graph << [this, RDF::PulStoreTerms.width, w]
        graph << [RDF::PulStoreTerms.width, RDF::RDFS.subPropertyOf, RDF::DC.extent]
      end
      unless [nil, ''].include? data['page_count']
        p = RDF::Literal.new(data['page_count'].to_i, datatype: RDF::XSD.int)
        graph << [this, RDF::PulStoreTerms.pageCount, p]
        graph << [RDF::PulStoreTerms.pageCount, RDF::RDFS.subPropertyOf, RDF::DC.extent]
      end

      graph
    end


    def canvas_from_page_hash(page)
      annotation = IIIF::Presentation::Annotation.new
      annotation.resource = image_resource_from_page_hash(page)
      canvas = IIIF::Presentation::Canvas.new
      canvas_uri = "#{PREFIXES[:lae].to_s}pages/#{page['id']}"
      canvas['@id'] = canvas_uri
      canvas.label = page['display_label']
      canvas.width = annotation.resource['width']
      canvas.height = annotation.resource['height']
      canvas.images << annotation
      canvas
    end

    def image_resource_from_page_hash(page)
      base_uri = PulStore::ImageServerUtils.build_iiif_base_uri(page['id'])
      params = {service_id: base_uri}
      image_resource = IIIF::Presentation::ImageResource.create_image_api_image_resource(params)
      image_resource
    end

    LABEL_LOOKUP ||= ActiveSupport::OrderedHash[[
      ['title', 'Title'],
      ['alternative_title', 'Other Title'],
      ['series', 'Series'],
      ['creator', 'Creator'],
      ['contributors', 'Contributor'],
      ['geographic_origin', 'Origin'],
      ['publisher', 'Publisher'],
      ['date_created', 'Date'],
      ['genre', 'Item Type'],
      ['description', 'Description'],
      ['page_count', 'Page Count'],
      ['dimensions', 'Dimensions'],
      ['geographic_subject', 'Geographic Subject'],
      ['category', 'Category'],
      ['subject', 'Subject'],
      ['language', 'Language'],
      ['container', 'Container'],
      ['rights', 'Rights'],
    ]]

    def self.to_iiif_metadata(data)
      # Filter blanks (etc.)
      data.each do |k,v|
        if v.kind_of?(Array) && (v.all?{|v| v.blank?} || v.empty? )
          data.delete(k)
        elsif v.blank?
          data.delete(k)
        end
      end

      metadata = []

      LABEL_LOOKUP.each do |k,v|
        display_label = v
        display_val = nil
        if ['title'].include?(k)
          display_val = data[k][0]
        elsif k == 'date_created' && data.has_key?('earliest_created') && data.has_key?('latest_created')
          display_val = "#{data['earliest_created']}-#{data['latest_created']}"
        elsif k == 'dimensions' && data.has_key?('height_in_cm') && data.has_key?('width_in_cm')
          display_val = "#{data['width_in_cm']} cm. × #{data['height_in_cm']} cm."
        elsif ['subject','geographic_subject','language'].include?(k)
          display_val = []
          data[k].each { |member| display_val << member['label'] }
        elsif k == 'geographic_origin'
          display_val = data[k]['label']
        elsif k == 'genre'
          display_val = []
          data[k].each { |member| display_val << member['pul_label'] }
        elsif k == 'container'
          display_val = "Box #{data['box']['physical_number']}, Folder #{data['physical_number']}"
        else
          display_val = data[k]
        end

        if display_val.kind_of?(Array)
          if display_val.length > 1 # pluralize the label
            display_label = display_label.pluralize(display_val.length)
          else # just make the value a regular string
            display_val = display_val[0]
          end
        end

        unless display_val.nil?
          metadata << { label: display_label, value: display_val }
        end
      end
      metadata
    end



    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: return nil if workflow_state is not "In Production". Default: true
    def to_folder_export_hash(opts={})
      unsolrize = opts.fetch(:unsolrize, true)
      prod_only = opts.fetch(:prod_only, true)

      if prod_only && self.workflow_state != 'In Production'
        return nil
      end

      excludes = PUL_STORE_CONFIG['lae_export_exclude']
      folder_h = self.to_solr.except(*excludes['folder'])


      # Bring in Data stored in AR models
      unless folder_h['desc_metadata__geographic_subject_tesim'].blank?
        geo_subjects = []
        folder_h['desc_metadata__geographic_subject_tesim'].each do |g_str|
          geo_subjects << PulStore::Lae::Area.where(label: g_str).first.attributes.except('id')
        end
        folder_h['geographic_subject'] = geo_subjects unless geo_subjects.empty?
        folder_h.delete('desc_metadata__geographic_subject_tesim')
      end

      unless folder_h['desc_metadata__subject_tesim'].blank?
        subjects = []
        folder_h['desc_metadata__subject_tesim'].each do |s|
          subjects << PulStore::Lae::Subject.where(label: s).first.attributes.except('id', 'category_id')
        end
        folder_h['subject'] = subjects unless subjects.empty?
        folder_h.delete('desc_metadata__subject_tesim')
      end

      unless folder_h['desc_metadata__genre_tesim'].blank?
        genres = []
        folder_h['desc_metadata__genre_tesim'].each do |s|
          genres << PulStore::Lae::Genre.where(pul_label: s).first.attributes.except('id')
        end
        folder_h['genre'] = genres unless genres.empty?
        folder_h.delete('desc_metadata__genre_tesim')
      end

      unless folder_h['desc_metadata__language_tesim'].blank?
        languages = []
        folder_h['desc_metadata__language_tesim'].each do |l|
          languages << Language.where(label: l).first.attributes.except('id')
        end
        folder_h['language'] = languages unless languages.empty?
        folder_h.delete('desc_metadata__language_tesim')
      end

      unless folder_h['desc_metadata__geographic_origin_tesim'].blank?
        origin_label = folder_h['desc_metadata__geographic_origin_tesim']
        origin_hash = PulStore::Lae::Area.where(label: origin_label).first.attributes.except('id')
        folder_h['geographic_origin'] = origin_hash.nil? ? origin_label : origin_hash
        folder_h.delete('desc_metadata__geographic_origin_tesim')
      end

      # Pages
      folder_h['pages'] = []
      self.pages(response_format: :solr).sort_by { |h| h['desc_metadata__sort_order_isi'] }.each do |p|
        data = p.except(*excludes['page'])
        folder_h['pages'] << (unsolrize ? unsolrize(data) : data)
      end

      # Box
      box_data = self.box.to_solr.except(*excludes['box'])
      folder_h['box'] = unsolrize ? unsolrize(box_data) : box_data

      project_data = self.project.to_solr.except(*excludes['project'])
      folder_h['project'] = unsolrize ? unsolrize(project_data) : project_data

      unsolrize ? unsolrize(folder_h) : folder_h

      rescue Exception => e
        logger.error(folder_h[:id])
        raise e
    end

    protected

    def unsolrize_key(s)
      if s.to_s.include? '__'
        s.scan( /^.+__(.+)_.+$/).last.first
      else
        s.to_s
      end
    end

    def unsolrize(hsh)
      Hash[hsh.map {|k, v| [unsolrize_key(k), v] }]
    end

  end
end

