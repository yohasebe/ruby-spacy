require "ruby-spacy"
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

# +------+----------+-----------+----------+--------------------------+
# | text | dep      | head text | head pos | children                 |
# +------+----------+-----------+----------+--------------------------+
# | 自動 | compound | 車        | NOUN     | []                       |
# | 運転 | compound | 車        | NOUN     | []                       |
# | 車   | nsubj    | 転嫁      | VERB     | [自動, 運転, は]         |
# | は   | case     | 車        | NOUN     | []                       |
# | 保険 | compound | 責任      | NOUN     | []                       |
# | 責任 | obj      | 転嫁      | VERB     | [保険, を]               |
# | を   | case     | 責任      | NOUN     | []                       |
# | 製造 | compound | 者        | NOUN     | []                       |
# | 者   | obl      | 転嫁      | VERB     | [製造, に]               |
# | に   | case     | 者        | NOUN     | []                       |
# | 転嫁 | ROOT     | 転嫁      | VERB     | [車, 責任, 者, する, 。] |
# | する | aux      | 転嫁      | VERB     | []                       |
# | 。   | punct    | 転嫁      | VERB     | []                       |
# +------+----------+-----------+----------+--------------------------+
