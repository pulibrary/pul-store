class TextRdfMetadata < WorkRdfMetadata

  map_predicates do |map|

    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.language(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

  end

end
