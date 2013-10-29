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

  end
end
