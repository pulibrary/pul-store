require File.expand_path('../../../../lib/rdf/item_properties', __FILE__)

class ItemRdfMetadata < ActiveFedora::NtriplesRDFDatastream


  map_predicates do |map|

    map.identifier({in: RDF::DC}) # what is this? NOID, or Physical id?

    # TODO: split into isPartOfCollection and isPartOfProject and index as 
    # facetable
    map.part_of(:to => "isPartOf", :in => RDF::DC) 

    map.type(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    
    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.sort_title(to: "sortTitle", in: RDF::PULItemWorks) do |index|
      index.as :sortable
      index.type :string
    end

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => "created", :in => RDF::DC) do |index|
      index.as :stored_searchable
    end
    
    map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end
    map.date_modified(:to => "modified", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

  end
end
