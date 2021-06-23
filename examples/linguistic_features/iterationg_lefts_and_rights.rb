require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("bright red apples on the tree")

puts "Text: " + doc

puts "Words to the left of 'apple': " + Spacy.generator_to_array(doc[2].lefts).to_s
puts "Words to the right of 'apple': " + Spacy.generator_to_array(doc[2].rights).to_s

puts "Num of the words to the left of 'apple': " + doc[2].n_lefts.to_s
puts "Num of the words to the right of 'apple': " + doc[2].n_rights.to_s
