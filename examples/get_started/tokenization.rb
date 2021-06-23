require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text"]
rows = []

doc.each do |token|
  rows << [token.text]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
