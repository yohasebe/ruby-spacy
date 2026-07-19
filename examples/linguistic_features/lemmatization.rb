# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

lemmatizer = nlp.get_pipe("lemmatizer")
puts "Lemmatizer mode: #{lemmatizer.mode}"

doc = nlp.read("I was reading the paper.")

headings = ["lemma"]
rows = []

doc.each do |token|
  rows << [token.lemma]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# Lemmatizer mode: rule
# +-------+
# | lemma |
# +-------+
# | I     |
# | be    |
# | read  |
# | the   |
# | paper |
# | .     |
# +-------+
