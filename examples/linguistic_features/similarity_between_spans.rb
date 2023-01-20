# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")
doc1 = nlp.read("I like salty fries and hamburgers.")
doc2 = nlp.read("Fast food tastes very good.")

puts "Doc 1: #{doc1.text}"
puts "Doc 2: #{doc2.text}"
puts "Similarity: #{doc1.similarity(doc2)}"

span1 = doc1.span(2, 2) # salty fries
span2 = doc1.span(5..5) # hamberger
puts "Span 1: #{span1.text}"
puts "Span 2: #{span2.text}"
puts "Similarity: #{span1.similarity(span2)}"

# Doc 1: I like salty fries and hamburgers.
# Doc 2: Fast food tastes very good.
# Similarity: 0.7687607012190486
# Span 1: salty fries
# Span 2: hamburgers
# Similarity: 0.6949787735939026
