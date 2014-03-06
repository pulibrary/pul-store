require 'marc'
require 'net/http'
require 'uri'
require 'rdf'

module PulStore::ExternalMetadataSource
  extend ActiveSupport::Concern
  
  included do
    has_metadata 'srcMetadata', type: PulStore::ExternalXmlMetadata
    # these two should probably have model MetadataSource that also includes a label, e.g. Voyager, PULFA
    has_attributes :dmd_source, :datastream => 'provMetadata', multiple: false
    has_attributes :source_dmd_type, :datastream => 'provMetadata', multiple: false
    has_attributes :dmd_system_id, :datastream => 'provMetadata', multiple: false
  end

  # Get the metadata from the source, set self.srcMetadata.content
  def harvest_external_metadata(dmd_source, system_id)
    self.dmd_source = RDF::URI.new(dmd_source.uri)
    self.source_dmd_type = dmd_source.media_type
    self.srcMetadata.mimeType = dmd_source.media_type
    self.dmd_system_id = system_id


    if dmd_source.label == "Voyager"
      mrx = self.class.get_marcxml(system_id)
      self.src_metadata = mrx

    elsif dmd_source.label == "PULFA"
      self.get_eadxml(system_id)
    # else # local?

    end
  end

  # Calling this before #harvest_external_metadata will not do anything

  # TODO: needs tests once complete
  def populate_attributes_from_external_metadata
    if !self.src_metadata.nil?
      if self.is_a? Item
        self.contributor = self.class.contributors_from_marc(self.src_metadata)
        self.creator = self.class.creator_from_marc(self.src_metadata)
        self.date_created = self.class.date_from_marc(self.src_metadata)
        self.sort_title = self.class.sort_title_from_marc(self.src_metadata)
        self.title = self.class.title_from_marc(self.src_metadata)
      end
      # Do more if we're a more specific class
      if self.instance_of? Text
        self.abstract = self.class.abstract_from_marc(self.src_metadata)
        self.alternative_title = self.class.alternative_titles_from_marc(self.src_metadata)
        self.audience = self.class.audience_from_marc(self.src_metadata)
        self.citation = self.class.citation_from_marc(self.src_metadata)
        self.description = self.class.description_from_marc(self.src_metadata)
        self.extent = self.class.extent_from_marc(self.src_metadata)
        self.has_part = self.class.has_parts_from_marc(self.src_metadata)
        self.language = self.class.language_from_marc(self.src_metadata)
        self.provenance = self.class.provenance_from_marc(self.src_metadata)
        self.publisher = self.class.publisher_from_marc(self.src_metadata)
        self.rights = self.class.rights_from_marc(self.src_metadata)
        self.series = self.class.series_from_marc(self.src_metadata)
        self.subject = self.class.subject_from_marc(self.src_metadata)
        self.toc = self.class.toc_from_marc(self.src_metadata)


      end
      self
    end
  end

  def src_metadata=(io)
    self.srcMetadata.content=io
  end

  def src_metadata
    self.srcMetadata.content
  end

  module ClassMethods

    def get_marcxml(system_id)
      uri = URI.join(PUL_STORE_CONFIG['voyager_datasource'], system_id)
      uri.query = URI.encode_www_form(format: 'marc')
      res = Net::HTTP.get_response(uri)
      if res.code == '200'
        res.body
      # else # TODO
      end
    end

    def get_eadxml(system_id)
      uri = URI.join(PUL_STORE_CONFIG['pulfa_datasource'], system_id)
      uri.query = URI.encode_www_form(scope: :record)

      req = Net::HTTP::Get.new(uri)
      req.delete("Accept") if req.key? "Accept"
      req.add_field("Accept", "application/xml")

      req.each_header do |header_name, header_value|
        puts "#{header_name} : #{header_value}"
      end

      res = Net::HTTP.new(uri.host).start do |http|
        http.request(req)
      end

      if res.code == '200'
        res.body
      # else # TODO
      end
    end

    def abstract_from_marc(record)
      formated_fields_as_array(record, '520')
    end

    def alternative_titles_from_marc(record)
      record = negotiate_record(record)
      alt_title_field_tags = determine_alt_title_fields(record)
      alt_titles = []
      alt_title_field_tags.each do |tag| 
        record.fields(tag).each do |field| # some of these tags are repeatable
          exclude_subfields = tag == '246' ? ['i'] : []
          alt_titles << field.format(exclude_alpha: exclude_subfields)
          if field.has_linked_field?
            alt_titles << record.get_linked_field(field).format(exclude_alpha: exclude_subfields)
          end
        end
      end
      alt_titles
    end

    def audience_from_marc(record)
      formated_fields_as_array(record, '521')
    end

    def citation_from_marc(record)
      formated_fields_as_array(record, '524')
    end
    
    def contributors_from_marc(record)
      record = negotiate_record(record)

      fields = []
      contributors = []
      if creator_from_marc(record).empty? && record.has_any_7xx_without_t?
        fields.push *record.fields(['100','110','111'])
        fields.push *record.fields(['700', '710', '711']).select { |df| !df['t'] }
        # By getting all of the fields first and then formatting them we keep 
        # the linked field values adjacent to the romanized values. It's a small
        # thing, but may be useful.
        fields.each do |field| 
          contributors << field.format
          if field.has_linked_field?
            contributors << record.get_linked_field(field).format
          end
        end
      end
      contributors
    end

    # 1xx and/or 7xx without ‡t (7xx with ‡t map to contents)
    def creator_from_marc(record)
      record = negotiate_record(record)

      creator = []
      if record.has_1xx? and !record.has_any_7xx_without_t?
        field = record.fields(['100','110','111'])[0]
        creator << field.format
        if field.has_linked_field?
          creator << record.get_linked_field(field).format
        end
      end
      creator
    end

    def date_from_marc(record)
      record = negotiate_record(record)
      record.best_date
    end

    def description_from_marc(record)
      formated_fields_as_array(record, ['500','501','502','504','507','508',
        '511','510','513','514','515','516','518','522','525','526','530',
        '533','534','535','536','538','542','544','545','546','547','550',
        '552','555','556','562','563','565','567','580','581','583','584',
        '585','586','588','590'])
    end

    def extent_from_marc(record)
      formated_fields_as_array(record, '300')
    end


    # 700,710,711 fields that include a t; 730, and 740_x2.
    # TODO: These should become id.loc.gov URIs at some point, and the linked
    # fields should get a maybe get an rfc 5646[1] lang-script tag, since 
    # they'll still be literals (presumably). Lang will have to be inferred from 
    # the language of the resource (041[2]), and the script from the 880 ‡6[3]
    # 1. http://www.w3.org/2011/rdf-wg/track/issues/64
    # 2. http://www.loc.gov/marc/bibliographic/bd041.html
    # 3. http://www.loc.gov/marc/bibliographic/ecbdcntf.html
    def has_parts_from_marc(record)
      record = negotiate_record(record)
      parts = []

      fields = []
      record.fields(['700','710','711','730','740']).each do |field|
        if ['700','710','711'].include? field.tag and field['t']
          fields << field
        elsif field.tag == '740' && field.indicator1 == '2'
          fields << field
        elsif field.tag == '730'
          fields << field
        end
      end
      fields.each do |f|
        parts << f.format
        if f.has_linked_field?
          parts << record.get_linked_field(f).format
        end
      end
      parts
    end

    # TODO: URIs
    def language_from_marc(record)
      record = negotiate_record(record)
      
      codes = []

      from_fixed = record['008'].value[35,3]
      codes << from_fixed if !['   ', 'mul'].include? from_fixed

      record.fields('041').each do |df|
        df.select {|sf| 
          ['a','d','e','g'].include? sf.code
        }.map {|sf|
          sf.value 
        }.each do |c|
          if c.length == 3
            codes << c
          elsif c.length % 3 ==0
            codes.push *c.scan(/.{3}/)
          end
        end
      end
      # codes.uniq

      # TODO: start here w/ labels; we need languages in the test db!!!
      labels = []
      codes.uniq.each do |code|
        l = Language.where(code: code)[0].label
        labels << l if l
      end
      labels
    end

    def provenance_from_marc(record)
      formated_fields_as_array(record, ['541','561'])
    end

    def publisher_from_marc(record)
      formated_fields_as_array(record, '260', codes: ['b'])
    end

    def rights_from_marc(record)
      formated_fields_as_array(record, ['506','540'])
    end

    def sort_title_from_marc(record)
      title_from_marc(record, false)[0]
    end

    # TODO: URIs, eventually
    def series_from_marc(record)
      formated_fields_as_array(record, ['440','490','800','810','811','830'])
    end

    # TODO: URIs, eventually
    def subject_from_marc(record)
      formated_fields_as_array(record, ['600','610','611','630','648','650',
        '651','653','654','655','656','657','658','662','690'])
    end

    # TODO: URIs (from 1xx+240), eventually
    def title_from_marc(record, include_initial_article=true)
      # TODO: record should already be a MARC::Record when it comes in,
      # or check...is it a MARC::Record, is it a String that points to a file?, 
      # can we parse it?
      record = negotiate_record(record)
      title_tag = determine_primary_title_field(record)
      ti_field = record.fields(title_tag)[0]
      titles = []

      if title_tag == '245'
        ti = ti_field.format.split(' / ')[0]
        if !include_initial_article
          chop = record['245'].indicator2.to_i
          ti = ti[chop,ti.length-chop]
        end
        titles << ti

        if ti_field.has_linked_field?
          linked_field = record.get_linked_field(ti_field)
          vern_ti = linked_field.format.split(' / ')[0]
          if !include_initial_article
            chop = linked_field.indicator2.to_i
            vern_ti = vern_ti[chop,ti.length-chop]
          end
          titles << vern_ti
        end

      # todo: else need tests
      else
        # todo: exclude 'i' when 246
        titles << ti_field.format
        if ti_field.has_linked_field?
          titles << record.get_linked_field(ti_field).format
        end
      end
      titles # what if empty?? catch here or with validations?
    end


    # We squash together 505s with ' ; '
    def toc_from_marc(record)
      entry_sep = ' ; '
      record = negotiate_record(record)

      contents = []
          
      record.fields('505').each do |f|
        entry = f.format
        if f.has_linked_field?
          entry += " = "
          entry += record.get_linked_field(f).format
        end
        contents << entry
      end
      contents.join entry_sep
    end


    private
    @@bib_leader06_types = %w(a c d e f g i j k m o p r t)
    @@title_fields_by_pref = %w(245 240 130 246 222 210 242 243 247)

    def formated_fields_as_array(record, fields, hsh={})
      codes = hsh.has_key?(:codes) ? hsh[:codes] : nil

      vals = []

      record = negotiate_record(record)

      record = negotiate_record(record)
      record.fields(fields).each do |field|

        val = codes.nil? ? field.format : field.format(codes: codes)

        vals << val if val != ""

        if field.has_linked_field?
          linked_field = record.get_linked_field(field)
          val = codes.nil? ? linked_field.format : linked_field.format(codes: codes)
          vals << val if val != ""
        end

      end
      vals
      
    end


    # Normalize streams, filepaths, and MARC::Record instances to MARC::Record
    def negotiate_record(record)
      if record.instance_of? MARC::Record
        record
      elsif record.is_a? String and File.exists? record
        # could also catch Errno::ENAMETOOLONG: File name too long
        reader = MARC::XMLReader.new(record)
        # take the first if a collection
        reader.select { |r| r.leader[6].in? @@bib_leader06_types }[0]
      else
        reader = MARC::XMLReader.new(StringIO.new(record))
        # take the first if a collection
        reader.select { |r| r.leader[6].in? @@bib_leader06_types }[0]
      end
    end


    def determine_primary_title_field(record)
      (@@title_fields_by_pref & negotiate_record(record).tags)[0]
    end

    def determine_alt_title_fields(record)
      record = negotiate_record(record)
      other_title_fields = *@@title_fields_by_pref
      while !other_title_fields.empty? && !found_title_tag ||=false
        # the first one we find will be the title, the rest we want
        found_title_tag = record.tags.include? other_title_fields.shift
      end
      other_title_fields
    end



  end


end

