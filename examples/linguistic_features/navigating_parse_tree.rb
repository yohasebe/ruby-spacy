require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

lemmatizer = nlp.get_pipe("lemmatizer")
puts "Lemmatizer mode: " + lemmatizer.mode

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")

headings = ["text", "dep", "head text", "head pos", "children"]
rows = []

doc.each do |token|
  rows << [token.text, token.dep_, token.head.text, token.head.pos_, token.children.to_s]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
