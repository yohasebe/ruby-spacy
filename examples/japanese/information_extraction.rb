# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require("ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

nlp.add_pipe("merge_entities")
nlp.add_pipe("merge_noun_chunks")

texts = [
  "アメリカ合衆国の国土面積は日本の約25倍あります。",
  "現在1ドルは日本円で110円です。"
]

texts.each do |text|
  doc = nlp.read(text)
  doc.each do |token|
    puts "#{token.head.text} --> #{token.text}" if token.dep_ == "case"
  end
end

# アメリカ合衆国 --> の
# 国土面積 --> は
# 日本 --> の
# 現在1ドル --> は
# 日本円 --> で
