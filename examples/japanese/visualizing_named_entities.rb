# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "セバスチアン・スランが2007年にグーグルで自動運転車に取り組み始めたとき、社外の人間で彼のことを真剣に捉えている者はほとんどいなかった。"

doc = nlp.read(sentence)

ent_html = doc.displacy(style: "ent")

File.open(File.join(File.dirname(__FILE__), "outputs/test_ent.html"), "w") do |file|
  file.write(ent_html)
end
