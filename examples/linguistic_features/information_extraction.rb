# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

nlp.add_pipe("merge_entities")
nlp.add_pipe("merge_noun_chunks")

sentence = "Credit and mortgage account holders must submit their requests"
doc = nlp.read(sentence)

texts = [
  "Net income was $9.4 million compared to the prior year of $2.7 million.",
  "Revenue exceeded twelve billion dollars, with a loss of $1b."
]

texts.each do |text|
  doc = nlp.read(text)
  doc.each do |token|
    if token.ent_type_ == "MONEY"
      if %w[attr dobj].index token.dep_
        subj = Spacy.generator_to_array(token.head.lefts).select { |t| t.dep == "nsubj" }
        puts("#{subj[0].text}  --> #{token.text}") unless subj.empty?
      elsif token.dep_ == "pobj" && token.head.dep == "prep"
        puts "#{token.head.head.text} --> #{token.text}"
      end
    end
  end
end

# Net income --> $9.4 million
# the prior year --> $2.7 million
# Revenue --> twelve billion dollars
# a loss --> 1b
