require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("gimme that")

puts doc.tokens.join(" ")

# Add special case rule
special_case = [{ORTH: "gim"}, {ORTH: "me"}]
tokenizer = nlp.tokenizer
tokenizer.add_special_case("gimme", special_case)

# Check new tokenization
puts nlp.read("gimme that").tokens.join(" ")
