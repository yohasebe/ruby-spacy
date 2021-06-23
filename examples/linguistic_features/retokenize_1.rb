require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Credit and mortgage account holders must submit their requests"
doc = nlp.read(sentence)

headings = ["text", "pos", "dep", "head text"]
rows = []

doc.retokenize(doc[4].left_edge.i .. doc[4].right_edge.i)

doc.each do |token|
  rows << [token.text, token.pos_, token.dep_, token.head.text]
end

table = Terminal::Table.new rows: rows, headings: headings
print table
