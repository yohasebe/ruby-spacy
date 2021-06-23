require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("I love coffee")

headings = ["text", "orth", "shape", "prefix", "suffix", "is_alpha", "is_digit"]
rows = []

doc.each do |word|
  lexeme = doc.vocab[word.text]
  rows << [lexeme.text, lexeme.orth, lexeme.shape_, lexeme.prefix_, lexeme.suffix_, lexeme.is_alpha, lexeme.is_digit]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
