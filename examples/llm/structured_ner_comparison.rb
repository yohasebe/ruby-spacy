# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

# Compares spaCy's named entity recognition with an LLM's, using structured
# outputs so the LLM's answer comes back as a validated Ruby Hash.
# Requires the OPENAI_API_KEY environment variable
# (or swap in provider: :anthropic with ANTHROPIC_API_KEY).

nlp = Spacy::Language.new("en_core_web_sm")
text = "Mr. Best flew to New York on Saturday morning to meet Tim Cook of Apple."
doc = nlp.read(text)

schema = {
  type: "object",
  properties: {
    entities: {
      type: "array",
      items: {
        type: "object",
        properties: {
          text: { type: "string" },
          label: { type: "string", enum: %w[PERSON ORG GPE DATE TIME OTHER] }
        },
        required: %w[text label],
        additionalProperties: false
      }
    }
  },
  required: ["entities"],
  additionalProperties: false
}

llm_result = nlp.with_llm(provider: :openai) do |ai|
  ai.chat(
    system: "Extract all named entities from the user's text.",
    user: text,
    schema: schema
  )
end

puts "spaCy entities:"
doc.ents.each { |ent| puts "  #{ent.text} (#{ent.label})" }

puts "\nLLM entities:"
llm_result["entities"].each { |ent| puts "  #{ent["text"]} (#{ent["label"]})" }
