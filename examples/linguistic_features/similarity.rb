require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_lg")
doc1 = nlp.read("I like salty fries and hamburgers.")
doc2 = nlp.read("Fast food tastes very good.")

puts "Doc 1: " + doc1
puts "Doc 2: " + doc2
puts "Similarity: #{doc1.similarity(doc2)}"

