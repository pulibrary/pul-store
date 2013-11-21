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

  # Some mappings inspired by:
  # https://github.com/ruby-marc/ruby-marc/blob/master/lib/marc/dublincore.rb
    def title_from_marc(record)
      record = bib_record_from_marc_collection(record)

      titles=[]

      if record['245']
        titles << format_field(record['245']).split(' / ')[0]
        if record['245']['6']
          titles << format_field(get_linked_field(record, record['245'])).split(' / ')[0]
        end
      elsif record['240']
        titles << format_field(record['240'])
        if record['240']['6']
          titles << format_field(get_linked_field(record, record['240']))
        end
      elsif record['130']
        titles << format_field(record['130'])
        if record['130']['6']
          titles << format_field(get_linked_field(record, record['130']))
        end
      else
        # TODO raise?
        nil
      end
      titles
    end

    private
    # Returns the first bib record from a marc:collection
    def bib_record_from_marc_collection(records)
      bib_types = %w(a c d e f g i j k m o p r t)
      reader = MARC::XMLReader.new(records)
      reader.select { |r| r.leader[6].in? bib_types }[0]
    end

    @@alpha = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    def format_field(field, codes=@@alpha, separator=' ')
      # codes ||= %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
      subfield_values = []
      field.select { |sf| codes.include? sf.code }.each do |sf|
        subfield_values << sf.value
      end
      subfield_values.join(separator)
    end

    def get_linked_field(record, src_field)
      if src_field['6']
        idx = src_field['6'].split('-')[1].split('/')[0].to_i - 1
        record.select { |df| df.tag == '880' }[idx]
      end
    end

  end

end
