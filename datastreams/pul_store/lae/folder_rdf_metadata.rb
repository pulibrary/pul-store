require File.expand_path('../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::Lae::FolderRdfMetadata < PulStore::ItemRdfMetadata

  map_predicates do |map|

    map.alternative_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.extent(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.genre(to: 'format', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.geographic(to: 'coverage', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.language(in: RDF::DC) do |index|
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

  end





end

