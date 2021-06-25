require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

tokyo = nlp.get_lexeme("東京")
japan = nlp.get_lexeme("日本")
france = nlp.get_lexeme("フランス")

query = tokyo.vector - japan.vector + france.vector

headings = ["key", "text", "score"]
rows = []

results = nlp.most_similar(query, 20)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
