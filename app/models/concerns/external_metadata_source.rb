require 'net/http'
require 'uri'

module ExternalMetadataSource
  extend ActiveSupport::Concern
  
  included do
    # ?? delegate or has_attributes? Thought delegate was deprecated:
    # http://projecthydra.org/2013/10/31/new-activefedora-and-hydra-head-releases/

    # has_attributes :dmd_source, :datastream => 'provMetadata', multiple: false
    # has_attributes :dmd_source_id, :datastream => 'provMetadata', multiple: false

    delegate :dmd_source, to: 'provMetadata', multiple: false
    delegate :dmd_source_id, to: 'provMetadata', multiple: false
  end


  module ClassMethods
    def get_marcxml(source_id)
      uri = URI.join(PUL_STORE_CONFIG['voyager_datasource'], source_id)
      uri.query = URI.encode_www_form(format: :marc)
      res = Net::HTTP.get_response(uri)
      puts res.body if res.is_a?(Net::HTTPSuccess)
    end
  end

end
