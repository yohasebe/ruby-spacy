require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_lg")
doc = nlp.read("dog cat banana afskfsd")

headings = ["text", "has_vector", "vector_norm", "is_oov"]
rows = []

doc.each do |token|
  rows << [token.text, token.has_vector, token.vector_norm, token.is_oov]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table
