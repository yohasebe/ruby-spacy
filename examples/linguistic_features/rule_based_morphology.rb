require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Where are you?")

puts "Morph features of the third word: " + doc[2].morph.to_s
puts "POS of the third word: " + doc[2].pos_.to_s
