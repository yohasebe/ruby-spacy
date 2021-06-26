require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "I live in New York"
doc = nlp.read(sentence)

puts "Before: " + doc.tokens.collect{|t| t}.join(", ")

doc.retokenize(3, 4)

puts "After: " + doc.tokens.collect{|t| t}.join(", ")

# Before: I, live, in, New, York
# After: I, live, in, New York
