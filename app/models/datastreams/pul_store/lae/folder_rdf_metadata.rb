require File.expand_path('../../../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::Lae::FolderRdfMetadata < PulStore::ItemRdfMetadata

  property :alternative_title, predicate: RDF::DC.alternative do |index|
    index.as :stored_searchable
  end

  property :description, predicate: RDF::DC.description do |index|
    index.as :stored_searchable
  end

  property :height_in_cm, predicate: RDF::PulStoreTerms.heightInCM do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :width_in_cm, predicate: RDF::PulStoreTerms.widthInCM do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :page_count, predicate: RDF::PulStoreTerms.pageCount do |index|
    index.as :stored_sortable
    index.type :integer
  end

  property :genre, predicate: RDF::DC.format do |index|
    index.as :stored_searchable, :facetable
  end

  property :geographic_subject, predicate: RDF::DC.coverage do |index|
    index.as :stored_searchable, :facetable
  end

  property :geographic_origin, predicate: RDF::MARC_RELATORS.mfp do |index|
    index.as :stored_searchable, :facetable
  end

  property :language, predicate: RDF::DC.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :publisher, predicate: RDF::DC.publisher do |index|
    index.as :stored_searchable
  end

  property :rights, predicate: RDF::DC.rights do |index|
    index.as :stored_searchable_single_string
  end

  property :series, predicate: RDF::PulStoreTerms.isPartOfSeries do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: RDF::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end

  property :category, predicate: RDF::PulStoreTerms.category do |index|
    index.as :stored_searchable, :facetable
  end

end

