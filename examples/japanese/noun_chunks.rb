# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

doc = nlp.read("自動運転車は保険責任を製造者に転嫁する。")

headings = ["text", "root.text", "root.dep", "root.head.text"]
rows = []

doc.noun_chunks.each do |chunk|
  rows << [chunk.text, chunk.root.text, chunk.root.dep, chunk.root.head.text]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------------+-----------+----------+----------------+
# | text       | root.text | root.dep | root.head.text |
# +------------+-----------+----------+----------------+
# | 自動運転車 | 車        | nsubj    | 転嫁           |
# | 製造者     | 者        | obl      | 転嫁           |
# +------------+-----------+----------+----------------+
