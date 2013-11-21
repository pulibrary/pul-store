class TextRdfMetadata < ItemRdfMetadata

  map_predicates do |map|

    map.alternative_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.toc(to: 'tableOfContents', in: RDF::DC) do |index|
      index.as :stored_searchable
    end
    
    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.language(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

  end
end
