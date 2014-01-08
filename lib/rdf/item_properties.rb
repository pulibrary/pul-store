module RDF
  class PULStoreItems < Vocabulary("http://princeton.edu/pulstore/items/")
    property :sortTitle # sub of dc:title
    property :projectIdentifier # sub of dc:indentifier
    property :isPartOfProject # sub of dc:isPartOf
  end
end
