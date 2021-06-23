require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("アップルはイギリスの新興企業を10億ドルで買収しようとしている。")

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
