require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Autonomous cars shift insurance liability toward manufacturers"
doc = nlp.read(sentence)

dep_svg = doc.displacy('dep', false)

File.open(File.join(File.dirname(__FILE__), "outputs/test_dep.svg"), "w") do |file|
  file.write(dep_svg)
end
