require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "pos", "dep"]
rows = []

doc.each do |token|
  rows << [token.text, token.pos_, token.dep_]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
