# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

# Requires the ANTHROPIC_API_KEY environment variable

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The cat sat on the mat while the dog slept under the table.")

result = nlp.with_llm(provider: :anthropic) do |ai|
  ai.chat(
    system: "You are a linguistics tutor. Explain the syntactic structure briefly.",
    user: doc.linguistic_summary
  )
end

puts result
