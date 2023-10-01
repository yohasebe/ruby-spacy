# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "任天堂は1983年にファミコンを14,800円で発売した。"
doc = nlp.read(sentence)

headings = %w[text start end label]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------------+-------+-----+---------+
# | text       | start | end | label   |
# +------------+-------+-----+---------+
# | 任天堂     | 0     | 3   | ORG     |
# | 1983年     | 4     | 9   | DATE    |
# | ファミコン | 10    | 15  | PRODUCT |
# | 14,800円   | 16    | 23  | MONEY   |
# +------------+-------+-----+---------+
