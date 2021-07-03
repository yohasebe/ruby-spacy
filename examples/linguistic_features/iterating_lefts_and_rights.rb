require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("bright red apples on the tree")

puts "Text: " + doc.text

puts "Words to the left of 'apple': " + doc[2].lefts.map(&:text).join(", ")
puts "Words to the right of 'apple': " + doc[2].rights.map(&:text).join(", ")

puts "Num of the words to the left of 'apple': " + doc[2].n_lefts.to_s
puts "Num of the words to the right of 'apple': " + doc[2].n_rights.to_s

# Text: bright red apples on the tree
# Words to the left of 'apple': bright, red
# Words to the right of 'apple': on
# Num of the words to the left of 'apple': 2
# Num of the words to the right of 'apple': 1
