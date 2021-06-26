require "ruby-spacy"
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

# +----------+
# | text     |
# +----------+
# | アップル |
# | は       |
# | イギリス |
# | の       |
# | 新興     |
# | 企業     |
# | を       |
# | 10億     |
# | ドル     |
# | で       |
# | 買収     |
# | しよう   |
# | と       |
# | し       |
# | て       |
# | いる     |
# | 。       |
# +----------+
