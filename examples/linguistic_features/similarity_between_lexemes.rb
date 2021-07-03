require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

orange = nlp.vocab("orange")
lemon = nlp.vocab("lemon")

book = nlp.vocab("book")
magazine = nlp.vocab("magazine")

puts "orange <=> lemon:   #{orange.similarity(lemon)}"
puts "book   <=> magazine: #{book.similarity(magazine)}"
puts "orange <=> book: #{orange.similarity(book)}"

# orange <=> lemon:   0.7080526351928711
# book   <=> magazine: 0.4355940818786621
# orange <=> book: 0.12197211384773254
