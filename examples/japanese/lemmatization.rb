# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("私は論文を読んでいるところだった。")

headings = %w[text lemma]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +--------+--------+
# | text   | lemma  |
# +--------+--------+
# | 私     | 私     |
# | は     | は     |
# | 論文   | 論文   |
# | を     | を     |
# | 読ん   | 読む   |
# | で     | で     |
# | いる   | いる   |
# | ところ | ところ |
# | だっ   | だ     |
# | た     | た     |
# | 。     | 。     |
# +--------+--------+
