class PulStore::ExternalXmlMetadata < ActiveFedora::OmDatastream
  def prefix
    'src_metadata__'
  end
end
