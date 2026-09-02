# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("ja_core_news_sm")
doc = nlp.read("太郎は昨日、東京で花子に古い本を渡した。")

puts doc.syntax_tree

File.binwrite(File.join(File.dirname(__FILE__), "tree_ja_projection.png"),
              doc.syntax_tree(format: :png))
File.binwrite(File.join(File.dirname(__FILE__), "tree_ja_chunks.png"),
              doc.syntax_tree(style: :chunks, format: :png))
