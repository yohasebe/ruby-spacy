# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

tokyo = nlp.get_lexeme("東京")
japan = nlp.get_lexeme("日本")
france = nlp.get_lexeme("フランス")

query = tokyo.vector - japan.vector + france.vector

headings = %w[rank text score]
rows = []

results = nlp.most_similar(query, 20)
results.each_with_index do |lexeme, i|
  index = (i + 1).to_s
  rows << [index, lexeme.text, lexeme.score]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------+----------------+--------------------+
# | rank | text           | score              |
# +------+----------------+--------------------+
# | 1    | パリ           | 0.7376999855041504 |
# | 2    | フランス       | 0.7221999764442444 |
# | 3    | 東京           | 0.6697999835014343 |
# | 4    | ストラスブール | 0.631600022315979  |
# | 5    | リヨン         | 0.5939000248908997 |
# | 6    | Paris          | 0.574400007724762  |
# | 7    | ベルギー       | 0.5683000087738037 |
# | 8    | ニース         | 0.5679000020027161 |
# | 9    | アルザス       | 0.5644999742507935 |
# | 10   | 南仏           | 0.5547999739646912 |
# | 11   | ロンドン       | 0.5525000095367432 |
# | 12   | モンマルトル   | 0.5453000068664551 |
# | 13   | ブローニュ     | 0.5338000059127808 |
# | 14   | トゥールーズ   | 0.5275999903678894 |
# | 15   | バスティーユ   | 0.5213000178337097 |
# | 16   | フランス人     | 0.5194000005722046 |
# | 17   | ロレーヌ       | 0.5148000121116638 |
# | 18   | モンパルナス   | 0.513700008392334  |
# | 19   | 渡仏           | 0.5131000280380249 |
# | 20   | イタリア       | 0.5127000212669373 |
# +------+----------------+--------------------+
