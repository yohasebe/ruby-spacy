require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

# lemmatizer = nlp.get_pipe("lemmatizer")
# puts "Lemmatizer mode: " + lemmatizer.mode

doc = nlp.read("私は論文を読んでいるところだった。")

headings = ["text", "lemma"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_]
end

table = Terminal::Table.new rows: rows, headings: headings
table = Terminal::Table.new :rows puts table
