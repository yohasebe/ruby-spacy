require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

doc = nlp.read("自動運転車は保険責任を製造者に転嫁する。")

headings = ["text", "root.text", "root.dep", "root.head.text"]
rows = []

doc.noun_chunks.each do |chunk|
  rows << [chunk.text, chunk.root.text, chunk.root.dep_, chunk.root.head.text]
end

pp spacy.pipe_names
puts table
