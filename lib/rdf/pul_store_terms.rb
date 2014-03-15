module RDF
  # See pul-store/lib/vocabs/pul_store.ttl
  class PulStoreTerms < Vocabulary("http://princeton.edu/pulstore/terms/")
    property :barcode # sub of dc:identifier
    property :containerIsFull
    property :dmdSource # sub of dc:source
    property :dmdSystemId # sub of dc:indentifier
    property :errorNote # sub of dc:description
    property :isPartOfCollection# subproperty of dct:isPartOf
    property :isPartOfProject # sub of dc:isPartOf
    property :isPartOfSeries # subproperty of dct:isPartOf
    property :passedQc # sub of dc:description (??)
    property :projectIdentifier # sub of dc:indentifier
    property :projectLabel # sub of ?? (rdfs:label?)
    property :physicalLocation # sub of (??)
    property :receivedDate # sub of dc:date
    property :shippedDate # sub of dc:date
    property :state # sub of dc:description
    property :suppressed # sub of dc:description (??)
    property :sortOrder
    property :sortTitle # sub of dc:title
    property :sourceDmdType # sub of dc:type
    property :trackingNumber # sub of dc:identifier (??)
    property :heightInCM
    property :widthInCM
    property :pageCount
  end
end
