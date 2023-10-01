# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

sentence = "自動運転車は保険責任を製造者に転嫁する。"
doc = nlp.read(sentence)

dep_svg = doc.displacy(style: "dep", compact: false)

File.open(File.join(File.dirname(__FILE__), "test_dep.svg"), "w") do |file|
  file.write(dep_svg)
end
