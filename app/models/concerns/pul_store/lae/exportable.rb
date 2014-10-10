
require File.expand_path('../../../../../../lib/rdf/pul_store_terms', __FILE__)
require 'rdf'
require 'rdf/turtle'
require 'nokogiri'
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
                  xml.send(:field, v, name: k) unless blanks.include?(v)
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
                # static alternatives keep us from having to call to_export twice
                graph = PulStore::Lae::Folder.to_graph(export_hash)
                ttl = PulStore::Lae::Folder.to_ttl(graph)
                xml.send(:field, ttl, name: :ttl)
              end

            end
          end
        end    
      end
      return bob.to_xml
    end

    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    def to_graph(opts={})
      data = self.to_export(opts)
      self.class.to_graph(data)
    end

    # opts:
    #   unsolrize: get keys back to name in model where possible. Default: true
    #   prod_only: only return the hash if state it "In Production". Default: true
    def to_ttl(opts={})
      self.to_graph(opts).dump(:turtle, prefixes: PREFIXES)
    end
    
    # static version to be called if you already have the data hash    
    def self.to_graph(data)
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

    # static version to be called if you already have the graph
    def self.to_ttl(graph)
      graph.dump(:turtle, prefixes: PREFIXES)
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
    end

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
