require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("自動運転車は保険責任を製造者に転嫁する。")

headings = ["text", "dep", "head text", "head pos", "children"]
rows = []

doc.each do |token|
  rows << [token.text, token.dep, token.head.text, token.head.pos, token.children.map(&:text).join(", ")]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

 +------+----------+-----------+----------+------------------------+
 | text | dep      | head text | head pos | children               |
 +------+----------+-----------+----------+------------------------+
 | 自動 | compound | 車        | 92       |                        |
 | 運転 | compound | 車        | 92       |                        |
 | 車   | nsubj    | 転嫁      | 100      | 自動, 運転, は         |
 | は   | case     | 車        | 92       |                        |
 | 保険 | compound | 責任      | 92       |                        |
 | 責任 | obj      | 転嫁      | 100      | 保険, を               |
 | を   | case     | 責任      | 92       |                        |
 | 製造 | compound | 者        | 92       |                        |
 | 者   | obl      | 転嫁      | 100      | 製造, に               |
 | に   | case     | 者        | 92       |                        |
 | 転嫁 | ROOT     | 転嫁      | 100      | 車, 責任, 者, する, 。 |
 | する | aux      | 転嫁      | 100      |                        |
 | 。   | punct    | 転嫁      | 100      |                        |
 +------+----------+-----------+----------+------------------------+
