require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

tokyo = nlp.get_lexeme("Tokyo")
japan = nlp.get_lexeme("Japan")
france = nlp.get_lexeme("France")

query = tokyo.vector - japan.vector + france.vector

headings = ["key", "text", "score"]
rows = []

results = nlp.most_similar(query, 20)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
