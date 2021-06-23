require( "ruby-spacy")

nlp = Spacy::Language.new("ja_core_news_sm")

doc = nlp.read("これは文です。今私は「これは文です」と言いました。")


puts "doc has annotation SENT_START: " + doc.has_annotation("SENT_START").to_s

doc.sents.each do |sent|
  puts sent.text
end
