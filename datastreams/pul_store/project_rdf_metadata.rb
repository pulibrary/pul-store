require File.expand_path('../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::ProjectRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    # map.identifier({in: RDF::DC})

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.display_label(to: "label", in: RDF::RDFS) do |index|
      index.as :displayable, :facetable
    end

    map.project_identifier(to: 'projectIdentifier', in: RDF::PulStoreTerms) do |index|
      index.as :displayable
    end

  end
end
