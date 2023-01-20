# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("任天堂は1983年にファミコンを14,800円で発売した。")

headings = %w[text lemma pos tag dep]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma, token.pos, token.tag, token.dep]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------------+------------+-------+--------------------------+--------+
# | text       | lemma      | pos   | tag                      | dep    |
# +------------+------------+-------+--------------------------+--------+
# | 任天堂     | 任天堂     | PROPN | 名詞-固有名詞-一般       | nsubj  |
# | は         | は         | ADP   | 助詞-係助詞              | case   |
# | 1983       | 1983       | NUM   | 名詞-数詞                | nummod |
# | 年         | 年         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    |
# | に         | に         | ADP   | 助詞-格助詞              | case   |
# | ファミコン | ファミコン | NOUN  | 名詞-普通名詞-一般       | obj    |
# | を         | を         | ADP   | 助詞-格助詞              | case   |
# | 14,800     | 14,800     | NUM   | 名詞-数詞                | fixed  |
# | 円         | 円         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    |
# | で         | で         | ADP   | 助詞-格助詞              | case   |
# | 発売       | 発売       | VERB  | 名詞-普通名詞-サ変可能   | ROOT   |
# | し         | する       | AUX   | 動詞-非自立可能          | aux    |
# | た         | た         | AUX   | 助動詞                   | aux    |
# | 。         | 。         | PUNCT | 補助記号-句点            | punct  |
# +------------+------------+-------+--------------------------+--------+
