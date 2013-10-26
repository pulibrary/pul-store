require File.expand_path('../../../../lib/rdf/page_properties', __FILE__)

class PageRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.identifier({in: RDF::DC})

    map.display_label(to: "label", in: RDF::RDFS) do |index|
      index.as :displayable
      index.type :string
    end

    map.sort_order(to: "sortOrder", in: RDF::PULStorePages) do |index|
      index.as :stored_searchable
      index.type :integer
    end

    map.type(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(:to => "modified", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.part_of(:to => "isPartOf", :in => RDF::DC) 
    # index, eg. if is part of a Collection
    
    # map.resource_type do |index| # TODO: vocab
    #   index.as :stored_searchable, :facetable
    # end

  end
end
