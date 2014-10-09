require File.expand_path('../../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::PageRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  property :identifier, predicate: RDF::DC.identifier

  property :display_label, predicate: RDF::RDFS.label do |index|
    index.as :stored_searchable_single_string
  end

  property :sort_order, predicate: RDF::PulStoreTerms.sortOrder do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :type, predicate: RDF::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  property :part_of, predicate: RDF::DC.isPartOf
end
