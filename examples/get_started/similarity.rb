# frozen_string_literal: true

require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_lg")
doc1 = nlp.read("I like salty fries and hamburgers.")
doc2 = nlp.read("Fast food tastes very good.")

puts "Doc 1: #{doc1.text}"
puts "Doc 2: #{doc2.text}"
puts "Similarity: #{doc1.similarity(doc2)}"

# Doc 1: I like salty fries and hamburgers.
# Doc 2: Fast food tastes very good.
# Similarity: 0.7687607012190486
