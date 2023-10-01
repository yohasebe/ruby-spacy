# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Where are you?")

puts "Morph features of the third word: #{doc[2].morph}"
puts "POS of the third word: #{doc[2].pos}"

# Morph features of the third word: Case=Nom|Person=2|PronType=Prs
# POS of the third word: PRON
