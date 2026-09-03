# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("de_core_news_sm")
doc = nlp.read("Der alte Professor las gestern ein interessantes Buch.")

puts doc.syntax_tree

output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_de_projection.png"),
              doc.syntax_tree(format: :png))
