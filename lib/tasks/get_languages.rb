require 'rdf/rdfxml'
require 'csv'

# Gets the ISO639-2 languages from id.loc.gov and saves it as CSV.

SRC_URI="http://id.loc.gov/vocabulary/iso639-2.rdf"
MADS_LANGUAGE = RDF::URI.new("http://www.loc.gov/mads/rdf/v1#Language")
MADS_CODE = RDF::URI.new("http://www.loc.gov/mads/rdf/v1#code")
SAVE_AS = File.expand_path("../../../db/fixtures/iso639-2.csv", __FILE__)

lc_graph = RDF::Graph.load(SRC_URI, format: :rdfxml)
label_literal = RDF::Literal.new(nil, language: :en)

CSV.open(SAVE_AS, "wb", force_quotes: true) do |csv|
  lc_graph.query([nil, RDF.type, MADS_LANGUAGE]).each do |l|
    lang_row = []
    lang_row << l.subject.to_s
    # code
    lc_graph.query([l.subject, MADS_CODE, nil]).each do |t|
      lang_row << t.object.to_s
    end
    # label
    labels = lc_graph.query([l.subject, RDF::RDFS.label, nil]).select do |t| 
      t.object.language == :en
    end
    lang_row << labels[0].object.to_s
    csv << lang_row
  end
end

