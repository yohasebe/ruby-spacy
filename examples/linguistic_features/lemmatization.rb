require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

lemmatizer = nlp.get_pipe("lemmatizer")
puts "Lemmatizer mode: " + lemmatizer.mode

doc = nlp.read("I was reading the paper.")

headings = ["lemma"]
rows = []

doc.each do |token|
  rows << [token.lemma_]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
