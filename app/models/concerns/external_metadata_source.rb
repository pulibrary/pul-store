require 'marc'
require 'net/http'
require 'uri'

module ExternalMetadataSource
  extend ActiveSupport::Concern
  
  included do
    # these two should probably have model MetadataSource that also includes a label, e.g. Voyager, PULFA
    has_attributes :dmd_source, :datastream => 'provMetadata', multiple: false
    has_attributes :source_dmd_type, :datastream => 'provMetadata', multiple: false

    has_attributes :dmd_source_id, :datastream => 'provMetadata', multiple: false
  end

  # TODO. Stub:
  # def get_metadata 
  #   if dmd_source.label == "VOYAGER"
  #     self.get_marcxml(dmd_source_id)
  #   elsif dmd_source.label == "PULFA"
  #     self.get_eadxml(dmd_source_id)
  #   else # local?

  #   end
  # end


  module ClassMethods

    def get_marcxml(dmd_source_id)
      uri = URI.join(PUL_STORE_CONFIG['voyager_datasource'], dmd_source_id)
      uri.query = URI.encode_www_form(format: :marc)
      res = Net::HTTP.get_response(uri)
      if res.code == '200'
        res.body
      # else # TODO
      end
    end

    def get_eadxml(dmd_source_id)
      uri = URI.join(PUL_STORE_CONFIG['pulfa_datasource'], dmd_source_id)
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

    # Returns the title and vernacular title if present
    def title_from_marc(record, include_initial_article=true)
      record = bib_record_from_marc_collection(record)

      titles=[]

      if record['245']
        ti = record['245'].format.split(' / ')[0]
        if !include_initial_article
          chop = record['245'].indicator2.to_i
          ti = ti[chop,ti.length-chop]
        end
        titles << ti

        if record['245'].has_linked_field?
          linked_field = record.get_linked_field(record['245'])
          vern_ti = linked_field.format.split(' / ')[0]
          if !include_initial_article
            chop = linked_field.indicator2.to_i
            vern_ti = vern_ti[chop,ti.length-chop]
          end
          titles << vern_ti
        end

      # todo: these need tests
      elsif record['240']
        titles << record['240'].format
        if record['240'].has_linked_field?
          titles << record.get_linked_field(record['240']).format
        end
      elsif record['130']
        titles << record['130'].format
        if record['130'].has_linked_field?
          titles << record.get_linked_field(record['130']).format
        end
      else
        # TODO raise? or should we handle w/ validations?
        nil
      end
      titles
    end

    def sort_title_from_marc(record)
      title_from_marc(record, false)[0]
    end

    # 1xx and/or 7xx without ‡t (7xx with ‡t map to contents)
    def get_creator_from_marc(record)
      if record.is_a? String # i.e. file path
        record = bib_record_from_marc_collection(record)
      end

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

    def get_contributors_from_marc(record)
      if record.is_a? String # i.e. file path
        record = bib_record_from_marc_collection(record)
      end

      fields = []
      contributors = []
      if get_creator_from_marc(record) == [] && record.has_any_7xx_without_t?
        fields.push *record.fields(['100','110','111'])
        fields.push *record.fields(['700', '710', '711']).select { |df| !df['t'] }
        # fields.flatten
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

    private

    @@bib_leader06_types = %w(a c d e f g i j k m o p r t)
    # Returns the first bib record from a marc:collection (e.g. in case holdings 
    # are included)
    def bib_record_from_marc_collection(records)
      reader = MARC::XMLReader.new(records)
      reader.select { |r| r.leader[6].in? @@bib_leader06_types }[0]
    end

  end


end


