class PulStore::ProjectRdfMetadata < ActiveFedora::NtriplesRDFDatastream

  property :description, predicate: RDF::DC.description do |index|
    index.as :displayable
  end

  property :label, predicate: RDF::RDFS.label do |index|
    index.as :stored_searchable_single_string, :facetable
  end

  property :identifier, predicate: RDF::DC.identifier do |index|
    index.as :stored_searchable
  end

end
