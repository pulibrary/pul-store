require File.expand_path('../../lib/rdf/pul_store_terms', __FILE__)

class ProvRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  # http://www.w3.org/2005/Incubator/prov/wiki/What_Is_Provenance
  # For us, this is mostly anything to do with workflow.

  map_predicates do |map|

    map.barcode(to: "barcode", in: RDF::PulStoreTerms) do |index|
      index.type :string
      index.as :stored_searchable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.dmd_source(to: "dmdSource", in: RDF::PulStoreTerms) do |index|
      # The URI for the host system.
      index.as :stored_searchable, :facetable
    end

    map.dmd_system_id(to: "dmdSystemId", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.as :stored_searchable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.error_note(to: "errorNote", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.as :stored_searchable
    end

    map.full(to: "containerIsFull", in: RDF::PulStoreTerms) do |index|
      index.type :boolean
      index.as :stored_searchable
    end

    map.passed_qc(to: "passedQc", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.type :boolean
      index.as :stored_searchable
    end

    map.physical_location(to: "physicalLocation", in: RDF::PulStoreTerms) do |index|
      index.type :string
      index.as :stored_sortable
    end

    map.shipped_date(to: "shippedDate", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.type :date
      index.as :stored_sortable
    end

    map.state(to: "state", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.type :string
      index.as :stored_searchable, :facetable
    end

    map.suppressed(to: "suppressed", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.type :boolean
      index.as :stored_searchable
    end


    map.source_dmd_type(to: "sourceDmdType", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.as :stored_searchable, :facetable
    end

    map.received_date(to: "receivedDate", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.type :date
      index.as :stored_sortable
    end

    map.tracking_number(to: "trackingNumber", in: RDF::PulStoreTerms) do |index|
      # The identifier for the metadata within its host system
      index.as :stored_searchable
    end

    

  end

end
