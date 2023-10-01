# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("bright red apples on the tree")

puts "Text: #{doc.text}"

puts "Words to the left of 'apple': #{doc[2].lefts.map(&:text).join(", ")}"
puts "Words to the right of 'apple': #{doc[2].rights.map(&:text).join(", ")}"

puts "Num of the words to the left of 'apple': #{doc[2].n_lefts}"
puts "Num of the words to the right of 'apple': #{doc[2].n_rights}"

# Text: bright red apples on the tree
# Words to the left of 'apple': bright, red
# Words to the right of 'apple': on
# Num of the words to the left of 'apple': 2
# Num of the words to the right of 'apple': 1
