require File.expand_path('../../../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::Lae::FolderRdfMetadata < PulStore::ItemRdfMetadata

  map_predicates do |map|

    map.alternative_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.height_in_cm(to: 'heightInCM', in: RDF::PulStoreTerms) do |index|
      index.as :stored_searchable
    end

    map.width_in_cm(to: 'widthInCM', in: RDF::PulStoreTerms) do |index|
      index.as :stored_searchable
    end

    map.page_count(to: 'pageCount', in: RDF::PulStoreTerms) do |index|
      index.as :stored_searchable
    end

    map.genre(to: 'format', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.geographic_subject(to: 'coverage', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.geographic_origin(to: 'mfp', in: RDF::MARC_RELATORS) do |index|
      index.as :stored_searchable, :facetable
    end

    map.language(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
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

