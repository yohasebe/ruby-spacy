require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

nlp.add_pipe("merge_entities")
nlp.add_pipe("merge_noun_chunks")

sentence = "Credit and mortgage account holders must submit their requests"
doc = nlp.read(sentence)

texts = [
    "Net income was $9.4 million compared to the prior year of $2.7 million.",
    "Revenue exceeded twelve billion dollars, with a loss of $1b.",
]

texts.each do |text|
  doc = nlp.read(text)
  doc.each do |token|
    if token.ent_type_ == "MONEY"
      if ["attr", "dobj"].index token.dep_ 
        subj = Spacy.generator_to_array(token.head.lefts).select{|t| t.dep_ == "nsubj"}
        if !subj.empty?
          puts(subj[0].text + " --> " + token.text)
        end
      elsif token.dep_ == "pobj" and token.head.dep_ == "prep"
        puts token.head.head.text + " --> " + token.text
      end
    end
  end
end
