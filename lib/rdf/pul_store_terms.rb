module RDF
  class PulStoreTerms < Vocabulary("http://princeton.edu/pulstore/terms/")
    property :dmdSource # sub of dc:source
    property :dmdSystemId # sub of dc:indentifier
    property :isPartOfCollection# subproperty of dct:isPartOf
    property :isPartOfProject # sub of dc:isPartOf
    property :isPartOfSeries # subproperty of dct:isPartOf
    property :projectIdentifier # sub of dc:indentifier
    property :sortOrder
    property :sortTitle # sub of dc:title
    property :sourceDmdType # sub of dc:type
  end
end
