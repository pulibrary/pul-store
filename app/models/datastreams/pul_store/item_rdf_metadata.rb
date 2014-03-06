require File.expand_path('../../../../../lib/rdf/pul_store_terms', __FILE__)

class PulStore::ItemRdfMetadata < ActiveFedora::NtriplesRDFDatastream

  map_predicates do |map|

    map.identifier({in: RDF::DC})

    # # TODO: split into isPartOfCollection and isPartOfProject and index as 
    # # facetable
    # map.part_of(:to => "isPartOf", :in => RDF::DC) 

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => "created", :in => RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.sort_title(to: "sortTitle", in: RDF::PulStoreTerms) do |index|
      index.as :sortable
      index.type :string
    end

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    # consider mapping the Model type to this
    map.type(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

  end
end
