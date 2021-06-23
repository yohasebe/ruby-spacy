require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("自動運転車は保険責任を製造者に転嫁する。")

headings = ["text", "dep", "head text", "head pos", "children"]
rows = []

doc.each do |token|
  rows << [token.text, token.dep_, token.head.text, token.head.pos_, token.children.to_s]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
