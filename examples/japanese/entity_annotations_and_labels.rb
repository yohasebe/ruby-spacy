require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "同志社大学は日本の京都にある私立大学で、新島襄という人物が創立しました。" 
doc = nlp.read(sentence)

headings = ["text", "ent_iob", "ent_iob_", "ent_type_"]
rows = []

doc.each do |ent|
  rows << [ent.text, ent.ent_iob, ent.ent_iob_, ent.ent_type_]
end

table = Terminal::Table.new rows: rows, headings: headings
print table
