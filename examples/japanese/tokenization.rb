require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("アップルはイギリスの新興企業を10億ドルで買収しようとしている。")

headings = ["text"]
rows = []

doc.each do |token|
  rows << [token.text]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
