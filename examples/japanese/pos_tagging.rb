require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("任天堂は1983年にファミコンを14,800円で発売した。")

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
