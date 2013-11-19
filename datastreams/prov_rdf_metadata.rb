require File.expand_path('../../lib/rdf/prov_properties', __FILE__)

class ProvRdfMetadata < ActiveFedora::NtriplesRDFDatastream

  map_predicates do |map|

    map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(:to => "modified", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.dmd_source(to: "dmdSource", in: RDF::PULStoreProv) do |index|
      index.as :stored_searchable
    end

    map.dmd_source_id(to: "dmdSourceId", in: RDF::PULStoreProv) do |index|
      index.as :stored_searchable
    end

  end
end
