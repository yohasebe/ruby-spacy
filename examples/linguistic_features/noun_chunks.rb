require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

lemmatizer = nlp.get_pipe("lemmatizer")
puts "Lemmatizer mode: " + lemmatizer.mode

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")

headings = ["text", "root.text", "root.dep", "root.head.text"]
rows = []

doc.noun_chunks.each do |chunk|
  rows << [chunk.text, chunk.root.text, chunk.root.dep_, chunk.root.head.text]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
