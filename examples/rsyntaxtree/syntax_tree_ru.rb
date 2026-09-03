# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

nlp = Spacy::Language.new("ru_core_news_sm")
doc = nlp.read("Старый профессор читал в библиотеке интересную книгу.")

puts doc.syntax_tree

# ru_core_news_sm has no noun chunk iterator, so style: :chunks raises
# ArgumentError for this language; Russian morphology is rich, though
output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_ru_projection.png"),
              doc.syntax_tree(format: :png))
File.binwrite(File.join(output_dir, "tree_ru_morphology.png"),
              doc.syntax_tree(format: :png, morphology: true))
