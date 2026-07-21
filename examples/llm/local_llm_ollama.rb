# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

# Requires a running Ollama server (https://ollama.com):
#   ollama pull llama3.2
#   ollama serve
# No API key is needed.

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("I sat on the bank of the river.")

result = nlp.with_llm(provider: :ollama, model: "llama3.2") do |ai|
  ai.chat(
    system: "Identify the meaning of the word 'bank' in one short sentence.",
    user: doc.linguistic_summary
  )
end

puts result

# Any OpenAI-compatible server works the same way via base_url, e.g.:
#   nlp.with_llm(provider: :openai, base_url: "http://localhost:1234/v1",
#                access_token: "not-needed", model: "your-model") { |ai| ... }
