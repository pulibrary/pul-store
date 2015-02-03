require File.expand_path('../../../../../lib/rdf/pul_store_terms', __FILE__)

# class PulStore::ProvRdfMetadata < ActiveFedora::NtriplesRDFDatastream
class PulStore::ProvRdfMetadata < ActiveFedora::NtriplesRDFDatastream
  # http://www.w3.org/2005/Incubator/prov/wiki/What_Is_Provenance
  # For us, this is mostly anything to do with workflow, and possibly metadata sources.

  property :barcode, predicate: RDF::PulStoreTerms.barcode do |index|
    index.type :string
    index.as :stored_searchable_single_string
  end

  property :date_uploaded, predicate: RDF::DC.dateSubmitted do |index|
    index.type :datetime
    index.as :stored_sortable
  end

  property :dmd_source, predicate: RDF::PulStoreTerms.dmdSource do |index|
    # The URI for the host system.
    index.as :stored_searchable, :facetable
  end

  property :dmd_system_id, predicate: RDF::PulStoreTerms.dmdSystemId do |index|
    # The identifier for the metadata within its host system
    index.as :stored_searchable
  end

  property :date_modified, predicate: RDF::DC.modified do |index|
    index.type :datetime
    index.as :stored_sortable
  end

  property :error_note, predicate: RDF::PulStoreTerms.errorNote do |index|
    # The identifier for the metadata within its host system
    index.as :stored_searchable
  end

  property :full, predicate: RDF::PulStoreTerms.containerIsFull do |index|
    index.type :boolean
    index.as :stored_searchable
  end

  property :shareable, predicate: RDF::PulStoreTerms.containerIsShareable do |index|
    index.type :boolean
    index.as :stored_searchable
  end

  property :identifier, predicate: RDF::DC.identifier do |index|
    index.as :stored_searchable
  end

  property :passed_qc, predicate: RDF::PulStoreTerms.passedQc do |index|
    # The identifier for the metadata within its host system
    index.type :boolean
    index.as :stored_searchable
  end

  property :physical_location, predicate: RDF::PulStoreTerms.physicalLocation do |index|
    index.type :string
    index.as :stored_sortable
  end

  property :physical_number, predicate: RDF::PulStoreTerms.physicalNumber do |index|
    index.type :integer
    index.as :stored_sortable
  end

  property :project_label, predicate: RDF::PulStoreTerms.projectLabel do |index|
    # The URI for the host system.
    index.as :stored_searchable_single_string, :facetable
  end

  property :shipped_date, predicate: RDF::PulStoreTerms.shippedDate do |index|
    # The identifier for the metadata within its host system
    index.type :datetime
    index.as :stored_sortable
  end

  property :workflow_state, predicate: RDF::PulStoreTerms.state do |index|
    # The identifier for the metadata within its host system
    index.type :string
    index.as :stored_searchable, :facetable
  end

  property :suppressed, predicate: RDF::PulStoreTerms.suppressed do |index|
    # The identifier for the metadata within its host system
    index.type :boolean
    index.as :stored_searchable
  end

  property :source_dmd_type, predicate: RDF::PulStoreTerms.sourceDmdType do |index|
    # The identifier for the metadata within its host system
    index.as :stored_searchable, :facetable
  end

  property :received_date, predicate: RDF::PulStoreTerms.receivedDate do |index|
    # The identifier for the metadata within its host system
    index.type :datetime
    index.as :stored_sortable
  end

  property :tracking_number, predicate: RDF::PulStoreTerms.trackingNumber do |index|
    # The identifier for the metadata within its host system
    index.as :stored_searchable
  end

end
