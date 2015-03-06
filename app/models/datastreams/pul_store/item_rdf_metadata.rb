require File.expand_path('../../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::ItemRdfMetadata < ActiveFedora::NtriplesRDFDatastream

  property :identifier, predicate: RDF::DC.identifier

  property :contributor, predicate: RDF::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :creator, predicate: RDF::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :date_created, predicate: RDF::DC.created do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :earliest_created, predicate: RDF::PulStoreTerms.earliestCreated do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :latest_created, predicate: RDF::PulStoreTerms.latestCreated do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :sort_title, predicate: RDF::PulStoreTerms.sortTitle do |index|
    index.as :stored_sortable
    index.type :string
  end

  property :title, predicate: RDF::DC.title do |index|
    index.as :stored_searchable
  end

  property :type, predicate: RDF::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

end
