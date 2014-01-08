require File.expand_path('../../lib/rdf/pul_store_terms', __FILE__)
class TextRdfMetadata < ItemRdfMetadata

  map_predicates do |map|

    map.abstract(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.alternative_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.audience(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.citation(to: 'bibliographicCitation', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.extent(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.has_part(to: 'hasPart', in: RDF::DC) do |index|
      index.as :stored_searchable
    end
    
    map.language(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.provenance(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.publisher(in: RDF::DC) do |index|
      index.as :stored_searchable
    end
    
    map.rights(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.series(to: 'isPartOfSeries', in: RDF::PulStoreTerms) do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    
    map.toc(to: 'tableOfContents', in: RDF::DC) do |index|
      index.as :stored_searchable
    end
end
  
end
