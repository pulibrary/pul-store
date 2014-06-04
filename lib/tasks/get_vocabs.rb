require 'linkeddata'
require 'rdf/cli/vocab-loader'

vocab_sources = {
  lifecycle: {
    prefix: "http://purl.org/vocab/lifecycle/schema#", 
    source: "http://vocab.org/lifecycle/schema-20080603.rdf",
    strict: true
  },
  exif: {
    prefix: "http://www.w3.org/2003/12/exif/ns#",
    source: "http://www.w3.org/2003/12/exif/ns",
    strict: true
  }
  marc_relators: {
    prefix: "http://id.loc.gov/vocabulary/relators/",
    source: "http://id.loc.gov/vocabulary/relators.nt",
    strict: true
  }

}

vocab_sources.each do |id, v|
  begin
    out = StringIO.new
    loader = RDF::VocabularyLoader.new(id.to_s.upcase)
    loader.prefix = v[:prefix]
    loader.source = v[:source] if v[:source]
    loader.extra = v[:extra] if v[:extra]
    loader.strict = v.fetch(:strict, true)
    loader.output = out
    loader.run
    out.rewind
    File.open("#{File.dirname(__FILE__)}/../rdf/#{id}.rb", "w") {|f| f.write out.read}
  rescue
    puts "Failed to load #{id}: #{$!.message}"
  end
end
