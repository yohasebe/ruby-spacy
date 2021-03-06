require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_sm")

sentence = "自動運転車は保険責任を製造者に転嫁する。"
doc = nlp.read(sentence)

dep_svg = doc.displacy(style: 'dep', compact: false)

File.open(File.join(File.dirname(__FILE__), "test_dep.svg"), "w") do |file|
  file.write(dep_svg)
end
