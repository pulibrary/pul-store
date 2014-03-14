class PulStore::ProjectRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.description(in: RDF::DC) do |index|
      index.as :displayable
    end

    map.label(to: "label", in: RDF::RDFS) do |index|
      index.as :stored_searchable, :facetable
    end

    map.identifier(to: 'identifier', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

  end
end
