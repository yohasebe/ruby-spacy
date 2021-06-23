require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
