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

  end

end
