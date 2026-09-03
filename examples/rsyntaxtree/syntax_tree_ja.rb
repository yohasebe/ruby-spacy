# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("ja_core_news_sm")
doc = nlp.read("太郎は花子が書いた手紙を京都で読んだ。")

puts doc.syntax_tree

output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_ja_projection.png"),
              doc.syntax_tree(format: :png))
File.binwrite(File.join(output_dir, "tree_ja_chunks.png"),
              doc.syntax_tree(style: :chunks, format: :png))
