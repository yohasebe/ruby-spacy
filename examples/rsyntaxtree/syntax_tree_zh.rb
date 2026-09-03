# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("zh_core_web_sm")
doc = nlp.read("老教授昨天在图书馆读了一本有趣的书。")

puts doc.syntax_tree

# zh_core_web_sm has no noun chunk iterator, so style: :chunks raises
# ArgumentError for this language
output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_zh_projection.png"),
              doc.syntax_tree(format: :png))
