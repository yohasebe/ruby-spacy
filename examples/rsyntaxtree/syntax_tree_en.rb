# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The quick brown fox jumped over the lazy dog near the river.")

puts doc.syntax_tree

File.binwrite(File.join(File.dirname(__FILE__), "tree_en_projection.png"),
              doc.syntax_tree(format: :png))
File.binwrite(File.join(File.dirname(__FILE__), "tree_en_chunks.png"),
              doc.syntax_tree(style: :chunks, format: :png))
