require File.expand_path('../../../../../lib/rdf/pul_store_terms', __FILE__)
class PulStore::TextRdfMetadata < PulStore::ItemRdfMetadata

  property :abstract, predicate: RDF::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :alternative_title, predicate: RDF::DC.alternative do |index|
    index.as :stored_searchable
  end

  property :audience, predicate: RDF::DC.audience do |index|
    index.as :stored_searchable
  end

  property :citation, predicate: RDF::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  property :description, predicate: RDF::DC.description do |index|
    index.as :stored_searchable
  end

  property :extent, predicate: RDF::DC.extent do |index|
    index.as :stored_searchable
  end

  property :has_part, predicate: RDF::DC.hasPart do |index|
    index.as :stored_searchable
  end
  
  property :language, predicate: RDF::DC.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :provenance, predicate: RDF::DC.provenance do |index|
    index.as :stored_searchable
  end

  property :publisher, predicate: RDF::DC.publisher do |index|
    index.as :stored_searchable
  end
  
  property :rights, predicate: RDF::DC.rights do |index|
    index.as :stored_searchable
  end

  property :series, predicate: RDF::PulStoreTerms.isPartOfSeries do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: RDF::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end
  
  property :toc, predicate: RDF::DC.tableOfContents do |index|
    index.as :stored_searchable
  end
  
end
