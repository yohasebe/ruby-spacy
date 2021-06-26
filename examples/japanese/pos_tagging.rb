require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("任天堂は1983年にファミコンを14,800円で発売した。")

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------------+------------+-------+--------------------------+--------+--------+----------+---------+
# | text       | lemma      | pos   | tag                      | dep    | shape  | is_alpha | is_stop |
# +------------+------------+-------+--------------------------+--------+--------+----------+---------+
# | 任天堂     | 任天堂     | PROPN | 名詞-固有名詞-一般       | nsubj  | xxx    | true     | false   |
# | は         | は         | ADP   | 助詞-係助詞              | case   | x      | true     | true    |
# | 1983       | 1983       | NUM   | 名詞-数詞                | nummod | dddd   | false    | false   |
# | 年         | 年         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    | x      | true     | false   |
# | に         | に         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
# | ファミコン | ファミコン | NOUN  | 名詞-普通名詞-一般       | obj    | xxxx   | true     | false   |
# | を         | を         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
# | 14,800     | 14,800     | NUM   | 名詞-数詞                | fixed  | dd,ddd | false    | false   |
# | 円         | 円         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    | x      | true     | false   |
# | で         | で         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
# | 発売       | 発売       | VERB  | 名詞-普通名詞-サ変可能   | ROOT   | xx     | true     | false   |
# | し         | する       | AUX   | 動詞-非自立可能          | aux    | x      | true     | true    |
# | た         | た         | AUX   | 助動詞                   | aux    | x      | true     | true    |
# | 。         | 。         | PUNCT | 補助記号-句点            | punct  | 。     | false    | false   |
# +------------+------------+-------+--------------------------+--------+--------+----------+---------+
