# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("これは文です。今私は「これは文です」と言いました。")

puts "doc has annotation SENT_START: #{doc.has_annotation("SENT_START")}"

doc.sents.each do |sent|
  puts sent.text
end

# doc has annotation SENT_START: true
# これは文です。
# 今私は「これは文です」と言いました。
