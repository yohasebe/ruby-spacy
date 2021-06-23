require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "任天堂は80年代にファミリー・コンピュータを14,800円で発売した。"
doc = nlp.read(sentence)

headings = ["text", "start", "end", "label"]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

table = Terminal::Table.new rows: rows, headings: headings
print table
