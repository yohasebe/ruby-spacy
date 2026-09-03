# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The quick brown fox jumped over the lazy dog near the river.")

puts doc.syntax_tree

output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_en_projection.png"),
              doc.syntax_tree(format: :png))
File.binwrite(File.join(output_dir, "tree_en_chunks.png"),
              doc.syntax_tree(style: :chunks, format: :png))
# A shorter sentence for the morphology tables: every leaf becomes a box, so a
# long sentence draws a figure too wide to read
compact = nlp.read("He was sitting under the old tree.")
File.binwrite(File.join(output_dir, "tree_en_morphology.png"),
              compact.syntax_tree(format: :png, morphology: true))
