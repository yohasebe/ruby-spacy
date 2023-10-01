# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "同志社大学は日本の京都にある私立大学で、新島襄という人物が創立しました。"
doc = nlp.read(sentence)

headings = %w[text ent_iob ent_iob_ ent_type_]
rows = []

doc.each do |ent|
  rows << [ent.text, ent.ent_iob, ent.ent_iob_, ent.ent_type]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +--------+---------+----------+-----------+
# | text   | ent_iob | ent_iob_ | ent_type_ |
# +--------+---------+----------+-----------+
# | 同志社 | 3       | B        | ORG       |
# | 大学   | 1       | I        | ORG       |
# | は     | 2       | O        |           |
# | 日本   | 3       | B        | GPE       |
# | の     | 2       | O        |           |
# | 京都   | 3       | B        | GPE       |
# | に     | 2       | O        |           |
# | ある   | 2       | O        |           |
# | 私立   | 2       | O        |           |
# | 大学   | 2       | O        |           |
# | で     | 2       | O        |           |
# | 、     | 2       | O        |           |
# | 新島   | 3       | B        | PERSON    |
# | 襄     | 1       | I        | PERSON    |
# | と     | 2       | O        |           |
# | いう   | 2       | O        |           |
# | 人物   | 2       | O        |           |
# | が     | 2       | O        |           |
# | 創立   | 2       | O        |           |
# | し     | 2       | O        |           |
# | まし   | 2       | O        |           |
# | た     | 2       | O        |           |
# | 。     | 2       | O        |           |
# +--------+---------+----------+-----------+
