# frozen_string_literal: true

require "test_helper"
require "socket"

NLP_SM = Spacy::Language.new("en_core_web_sm")
NLP_LG = Spacy::Language.new("en_core_web_lg")

class SpacyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Spacy::VERSION
  end

  # ============================
  # Doc related methods
  # ============================
  # Tests with a name having a "test_py" prefix uses spaCy methods
  # directly without a ruby wrapper method (hence not defined in ruby-spacy.rb)
  def test_doc_each
    doc = NLP_SM.read("Hello everybody!")
    assert_equal doc.class.name, "Spacy::Doc"
    doc.each do |token|
      assert_equal token.class.name, "Spacy::Token"
    end
  end

  def test_doc_slice
    doc = NLP_SM.read("Give it back! He pleaded.")
    assert_equal doc[0].class.name, "Spacy::Token"
    assert_equal doc[0..].class.name, "Spacy::Span"
    assert_equal doc[0].text, "Give"
    assert_equal doc[-1].text, "."
  end

  def test_doc_span
    doc = NLP_SM.read("Give it back! He pleaded.")
    span1 = doc.span(0, 2)  # like [0, 1, 2, 3].slice(0, 2)
    span2 = doc.span(0..3)  # like [0, 1, 2, 3].slice(0 .. 3)
    span3 = doc[0..3]       # like [0, 1, 2, 3][0 .. 3]
    span4 = doc.span(4...6) # like [0, 1, 2, 3].slice(0 ... 3)
    span5 = span1[0..1]
    assert_equal span1.text, "Give it"
    assert_equal span2.text, "Give it back!"
    assert_equal span3.text, "Give it back!"
    assert_equal span4.text, "He pleaded"
    assert_equal span5.text, "Give it"
  end

  def test_doc_iteration
    doc = NLP_SM.read("Give it back!")
    results = []
    doc.each do |token|
      results << token.text
    end
    assert_equal results, ["Give", "it", "back", "!"]
  end

  def test_doc_len
    doc = NLP_SM.read("Give it back!")
    assert_equal doc.count, 4
    assert_equal doc.length, 4
    assert_equal doc.size, 4
    assert_equal doc.len, 4
  end

  def test_doc_py_char_span
    doc = NLP_SM.read("I like New York")
    span = doc.char_span(7, 15, "GPE")
    assert_equal span.text, "New York"
    assert_equal span.label_, "GPE"
  end

  def test_doc_similarity
    apples = NLP_LG.read("I like apples")
    oranges = NLP_LG.read("I like oranges")
    apples_oranges = apples.similarity(oranges)
    oranges_apples = oranges.similarity(apples)
    assert_equal apples_oranges, oranges_apples
  end

  def test_doc_retokenize
    doc = NLP_SM.read("I like David Bowie")
    attrs = { LEMMA: "David Bowie" }
    doc.retokenize(2, 4, attrs)
    assert_equal doc[2].text, "David Bowie"
    assert_equal doc[2].lemma, "David Bowie"
  end

  def test_doc_retokenize_split
    doc = NLP_SM.read("I live in NewYork")
    pos_in_doc = 3
    head_pos_in_split = 1
    ancestor_pos = 2
    attributes = { POS: %w[PROPN PROPN],
                   DEP: %w[pobj compound] }
    doc.retokenize_split(pos_in_doc, %w[New York], head_pos_in_split, ancestor_pos, attributes)
    assert_equal doc.tokens.collect(&:text).join(" "), "I live in New York"
    assert_equal doc.tokens[3].head.text, "York"
    assert_equal doc.tokens[4].head.text, "in"
  end

  def test_doc_noun_chunks
    doc = NLP_SM.read("A phrase with another phrase occurs.")
    chunks = doc.noun_chunks
    assert_equal chunks.size, 2
    assert_equal chunks[0].text, "A phrase"
    assert_equal chunks[1].text, "another phrase"
  end

  def test_doc_sents
    doc = NLP_SM.read("This is a sentence. Here's another.")
    sents = doc.sents
    assert_equal sents.size, 2
    assert_equal sents.collect { |s| s.root.text }, %w[is 's]
  end

  def test_doc_ents
    doc = NLP_SM.read("Mr. Best flew to New York on Saturday morning.")
    ents = doc.ents
    assert_equal ents[0].label, "PERSON"
    assert_equal ents[0].text, "Best"
  end

  def test_doc_py_has_vector
    doc = NLP_SM.read("I like apples")
    assert doc.has_vector
  end

  def test_doc_py_vector
    doc = NLP_LG.read("I like apples")
    assert_equal doc.vector.dtype, "float32"
    assert_equal doc.vector.shape.to_s, "(300,)"
  end

  def test_openai_query1
    doc = NLP_SM.read("The Beatles were an English rock band formed in Liverpool in 1960.")
    res = doc.openai_query(prompt: "Extract the topic of the document and list 10 entities (names, concepts, locations, etc.) that are relevant to the topic.", max_tokens: 1000)
    assert_instance_of String, res
  end

  def test_openai_query2
    doc = NLP_SM.read("The Beatles released 12 studio albums")
    res = doc.openai_query(prompt: "List token data of each of the words used in the sentence. Add 'meaning' property and value (brief semantic definition) to each token data. Output as a JSON object.", max_tokens: 1000)
    assert_instance_of String, res
  end

  def test_openai_completion
    doc = NLP_SM.read("Vladimir Nabokov was a")
    res = doc.openai_completion
    assert_instance_of String, res
  end

  def test_openai_embeddings
    doc = NLP_SM.read("Vladimir Nabokov was a Russian-American novelist, poet, translator and entomologist.")
    res = doc.openai_embeddings
    assert_instance_of Array, res
  end

  def test_openai_query_with_max_completion_tokens
    doc = NLP_SM.read("Hello world")
    res = doc.openai_query(prompt: "Translate to Japanese", max_completion_tokens: 100)
    assert_instance_of String, res
  end

  def test_openai_completion_with_max_completion_tokens
    doc = NLP_SM.read("Ruby is a")
    res = doc.openai_completion(max_completion_tokens: 100)
    assert_instance_of String, res
  end

  def test_openai_embeddings_dimensions
    doc = NLP_SM.read("Test sentence.")
    res = doc.openai_embeddings
    assert_instance_of Array, res
    assert_equal 1536, res.length # text-embedding-3-small default dimensions
  end

  # ============================
  # Language related methods
  # ============================

  def test_language_disable_pipes
    nlp = Spacy::Language.new
    nlp.select_pipes(disable: %w[tagger parser])
    nlp.initialize
    assert_empty %w[tagger parser] - nlp.disabled
    assert_empty %w[senter] - NLP_SM.disabled
  end

  def test_language_get_lexeme
    nlp = Spacy::Language.new
    king = nlp.get_lexeme("king")
    assert_equal king.text, "king"
  end

  def test_language_most_similar
    tokyo = NLP_LG.get_lexeme("Tokyo")
    japan = NLP_LG.get_lexeme("Japan")
    france = NLP_LG.get_lexeme("France")
    query = tokyo.vector - japan.vector + france.vector
    result = NLP_LG.most_similar(query, 10)
    assert result.collect { |r| r[:text] }.index("Paris") ||
      result.collect { |r| r[:text] }.index("PARIS")
  end

  def test_language_pipe
    texts = ["Imagine there's no heaven", "It's easy if you try", "No hell below us", "Above us, only sky."]
    docs = NLP_LG.pipe(texts, disable: [], batch_size: 50)
    assert docs.first.class.name, "Spacy::Doc"
  end

  # ============================
  # Span related methods
  # ============================
  # Tests with a name having a "test_py" prefix uses spaCy methods
  # directly without a ruby wrapper method (hence not defined in ruby-spacy.rb)

  def test_span_each
    doc = NLP_SM.read("Hello everybody!")
    span = doc[0..]
    assert_equal span.class.name, "Spacy::Span"
    span.each do |token|
      assert_equal token.class.name, "Spacy::Token"
    end
  end

  def test_span_slice
    doc = NLP_SM.read("Give it back! He pleaded.")
    span1 = doc[0..3]
    span2 = doc.span(0..3)
    span3 = doc[0...4]
    span4 = doc.span(0, 4)
    assert_equal span1.text, span2.text
    assert_equal span2.text, span3.text
    assert_equal span3.text, span4.text
  end

  def test_span_size
    doc = NLP_SM.read("Give it back! He pleaded.")
    span = doc[0..3]
    assert_equal span.size, 4
  end

  def test_span_similarity
    nlp = Spacy::Language.new("en_core_web_lg")
    doc = nlp.read("green apples and red oranges")
    green_apples = doc.span(0, 2)
    red_oranges = doc.span(3, 2)
    apples_oranges = green_apples.similarity(red_oranges)
    oranges_apples = red_oranges.similarity(green_apples)
    assert_equal apples_oranges, oranges_apples
  end

  def test_span_ents
    doc = NLP_SM.read("Mr. Best flew to New York on Saturday morning.")
    ents = doc.span(0, 3).ents
    assert_equal ents[0].label_, "PERSON"
    assert_equal ents[0].text, "Best"
  end

  def test_span_sent
    doc = NLP_SM.read("Give it back! He pleaded.")
    assert_equal doc.span(0, 1).sent.text, "Give it back!"
  end

  def test_span_noun_chunks
    doc = NLP_SM.read("A phrase with another phrase occurs.")
    chunks = doc.span(2, 4).noun_chunks
    assert_equal chunks.size, 1
    assert_equal chunks[0].text, "another phrase"
  end

  def test_span_as_doc
    doc = NLP_SM.read("I like New York in Autumn.")
    span = doc[2..5]
    doc2 = span.as_doc
    assert_equal doc2.class.name, "Spacy::Doc"
  end

  def test_span_py_root
    doc = NLP_SM.read("I like New York in Autumn.")
    root = doc.span(2, 5).root
    assert_equal root.text, "York"
  end

  def test_span_conjuncts
    doc = NLP_SM.read("I like apples and oranges")
    assert_equal doc.span(2, 1).conjuncts[0].text, "oranges"
  end

  def test_span_lefts
    doc = NLP_SM.read("I like New York in Autumn.")
    assert_equal doc.span(3, 1).lefts[0].text, "New"
    assert_equal doc.span(3, 1).n_lefts, 1
  end

  def test_span_rights
    doc = NLP_SM.read("I like New York in Autumn.")
    assert_equal doc.span(3, 1).rights[0].text, "in"
    assert_equal doc.span(3, 1).n_rights, 1
  end

  def test_span_subtree
    doc = NLP_SM.read("Give it back! He pleaded.")
    assert_equal doc.span(0..3).subtree.size, 4
  end

  # ============================
  # Token related methods
  # ============================

  def test_token_subtree
    doc = NLP_SM.read("I like New York in Autumn.")
    token = doc[3] # "York"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.subtree.map(&:text), %w[New York in Autumn]
  end

  def test_token_ancestors
    doc = NLP_SM.read("I like New York in Autumn.")
    token = doc[4] # "in"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.ancestors.map(&:text), %w[York like]
  end

  def test_token_children
    doc = NLP_SM.read("I like New York in Autumn.")
    token = doc[1] # "like"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.children.map(&:text), %w[I York .]
  end

  def test_token_lefts
    doc = NLP_SM.read("I like New York in Autumn.")
    token = doc[1] # "like"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.lefts.map(&:text), ["I"]
  end

  def test_token_rights
    doc = NLP_SM.read("I like New York in Autumn.")
    token1 = doc[1] # "like"
    assert_equal token1.class.name, "Spacy::Token"
    assert_equal token1.rights.map(&:text), ["York", "."]
    token2 = doc[-1]
    assert_equal token2.to_s, "."
  end

  def test_token_morph
    doc = NLP_SM.read("I like New York in Autumn.")
    token1 = doc[1]  # like
    token2 = doc[-2] # Autumn
    assert_equal token1.morphology["Tense"], "Pres"
    assert_equal token1.morphology["VerbForm"], "Fin"
    assert_equal token2.morphology(hash: false), "Number=Sing"
  end

  def test_token_method_missing
    doc = NLP_SM.read("I like New York in Autumn.")
    tokens = doc.tokens
    selected = tokens.reject(&:is_stop)
    assert_equal selected.map(&:text), ["like", "New", "York", "Autumn", "."]
  end

  # ============================
  # Matcher related methods
  # ============================

  def test_matcher_match
    matcher = NLP_SM.matcher
    matcher.add("US_PRESIDENT", [[{ lower: "barack" }, { lower: "obama" }]])

    doc = NLP_SM.read("Barack Obama was the 44th president of the United States")

    match = matcher.match(doc).first

    span = Spacy::Span.new(doc, start_index: match[:start_index], end_index: match[:end_index], options: { label: match[:match_id] })
    assert_equal span.text, "Barack Obama"
    assert_equal span.label_, "US_PRESIDENT"
  end

  # ============================
  # Lexeme related methods
  # ============================

  def test_lexeme
    doc = NLP_SM.read("I like New York in Autumn.")
    token = doc.tokens[-2] # Autumn
    lexeme_1 = token.lexeme
    lexeme_2 = NLP_SM.vocab "Summer"
    assert lexeme_1.instance_of?(Spacy::Lexeme)
    assert lexeme_2.instance_of?(Spacy::Lexeme)
  end

  def test_lexeme_similarity
    lexeme_lemon = NLP_LG.vocab "lemon"
    lexeme_orange = NLP_LG.vocab "orange"
    lexeme_book = NLP_LG.vocab "book"
    assert lexeme_lemon.similarity(lexeme_orange) > lexeme_lemon.similarity(lexeme_book)
  end

  # ============================
  # Timeout and Retrial
  # ============================

  def test_language_initialization_with_timeout
    assert_raises(RuntimeError, "PyCall execution timed out after 0.1 seconds") do
      Timeout.stub :timeout, ->(*_args) { raise Timeout::Error } do
        Spacy::Language.new("en_core_web_sm", timeout: 0.1)
      end
    end
  end

  def test_language_initialization_with_retries
    PyCall.stub :exec, ->(*_args) { raise StandardError.new("Simulated failure") } do
      assert_raises(RuntimeError, "Failed to initialize Spacy after 3 attempts: Simulated failure") do
        Spacy::Language.new("en_core_web_sm", max_retrial: 3)
      end
    end
  end

  # ============================
  # Serialization
  # ============================

  def test_doc_to_bytes
    doc = NLP_SM.read("Apple Inc. was founded by Steve Jobs.")
    bytes = doc.to_bytes
    assert_instance_of String, bytes
    assert bytes.encoding == Encoding::BINARY
    assert bytes.length > 0
  end

  def test_doc_from_bytes
    original_doc = NLP_SM.read("Apple Inc. was founded by Steve Jobs.")
    bytes = original_doc.to_bytes

    restored_doc = Spacy::Doc.from_bytes(NLP_SM, bytes)
    assert_instance_of Spacy::Doc, restored_doc
    assert_equal original_doc.text, restored_doc.text
    assert_equal original_doc.tokens.map(&:text), restored_doc.tokens.map(&:text)
  end

  def test_doc_serialization_preserves_entities
    doc = NLP_SM.read("Apple Inc. was founded by Steve Jobs in California.")
    bytes = doc.to_bytes

    restored_doc = Spacy::Doc.from_bytes(NLP_SM, bytes)
    original_ents = doc.ents.map { |e| [e.text, e.label] }
    restored_ents = restored_doc.ents.map { |e| [e.text, e.label] }
    assert_equal original_ents, restored_ents
  end

  # ============================
  # PhraseMatcher
  # ============================

  def test_phrase_matcher_basic
    matcher = NLP_SM.phrase_matcher
    matcher.add("PRODUCT", ["iPhone", "MacBook Pro"])

    doc = NLP_SM.read("I bought an iPhone and a MacBook Pro yesterday.")
    matches = matcher.match(doc)

    assert_equal 2, matches.length
    assert matches.all? { |m| m.is_a?(Spacy::Span) }
    texts = matches.map(&:text)
    assert_includes texts, "iPhone"
    assert_includes texts, "MacBook Pro"
  end

  def test_phrase_matcher_case_insensitive
    matcher = NLP_SM.phrase_matcher(attr: "LOWER")
    matcher.add("COMPANY", ["apple", "google", "microsoft"])

    doc = NLP_SM.read("Apple and GOOGLE are tech companies. Microsoft is too.")
    matches = matcher.match(doc)

    assert_equal 3, matches.length
    texts = matches.map(&:text)
    assert_includes texts, "Apple"
    assert_includes texts, "GOOGLE"
    assert_includes texts, "Microsoft"
  end

  def test_phrase_matcher_with_labels
    matcher = NLP_SM.phrase_matcher
    matcher.add("FRUIT", ["apple", "orange"])
    matcher.add("COLOR", ["red", "blue"])

    doc = NLP_SM.read("I like red apple and blue orange.")
    matches = matcher.match(doc)

    labels = matches.map(&:label)
    assert_includes labels, "FRUIT"
    assert_includes labels, "COLOR"
  end

  def test_phrase_matcher_no_matches
    matcher = NLP_SM.phrase_matcher
    matcher.add("PRODUCT", ["iPhone", "MacBook"])

    doc = NLP_SM.read("I went to the store.")
    matches = matcher.match(doc)

    assert_empty matches
  end

  # ============================
  # New tests for improvements
  # ============================

  def test_doc_ents_returns_spans
    doc = NLP_SM.read("Mr. Best flew to New York on Saturday morning.")
    ents = doc.ents
    ents.each do |ent|
      assert_instance_of Spacy::Span, ent
      assert_instance_of String, ent.label
      assert_instance_of String, ent.text
    end
  end

  def test_token_idx
    doc = NLP_SM.read("Hello world!")
    tokens = doc.tokens
    assert_equal 0, tokens[0].idx
    assert_equal 6, tokens[1].idx
  end

  def test_language_invalid_model_name
    assert_raises(ArgumentError) do
      Spacy::Language.new("en'; import os; os.system('echo hacked') #")
    end
  end

  def test_doc_span_negative_index
    doc = NLP_SM.read("Give it back! He pleaded.")
    span = doc.span(-3..-1)
    assert_equal "He pleaded.", span.text
  end

  def test_doc_span_endless_range
    doc = NLP_SM.read("Give it back! He pleaded.")
    span = doc.span(4..)
    assert_equal "He pleaded.", span.text
  end

  def test_respond_to_missing
    doc = NLP_SM.read("Hello world")
    token = doc.tokens.first
    span = doc[0..1]
    lexeme = NLP_SM.vocab("hello")

    # Python attributes that exist
    assert doc.respond_to?(:has_vector)
    assert token.respond_to?(:is_stop)
    assert span.respond_to?(:start)

    # Ruby methods
    assert doc.respond_to?(:tokens)
    assert token.respond_to?(:lemma)
    assert span.respond_to?(:label)
    assert lexeme.respond_to?(:lower)
  end

  def test_openai_embeddings_with_dimensions
    doc = NLP_SM.read("Test sentence.")
    res = doc.openai_embeddings(dimensions: 256)
    assert_instance_of Array, res
    assert_equal 256, res.length
  end

  def test_openai_query_with_response_format
    doc = NLP_SM.read("List three colors.")
    res = doc.openai_query(
      prompt: "Return a JSON object with a key 'colors' containing an array of color names from the text.",
      response_format: { type: "json_object" }
    )
    assert_instance_of String, res
    parsed = JSON.parse(res)
    assert_instance_of Hash, parsed
  end

  def test_memory_zone
    major, minor = Spacy::SpacyVersion.split(".").map(&:to_i)
    if major > 3 || (major == 3 && minor >= 8)
      NLP_SM.memory_zone do
        doc = NLP_SM.read("Hello world")
        assert_instance_of Spacy::Doc, doc
      end
    else
      assert_raises(NotImplementedError) do
        NLP_SM.memory_zone { }
      end
    end
  end

  def test_inspect_does_not_include_py_objects
    doc = NLP_SM.read("Hello")
    # instance_variables_to_inspect is defined for Ruby 4.0+
    if doc.respond_to?(:instance_variables_to_inspect) && RUBY_VERSION >= "4.0"
      inspect_str = doc.inspect
      refute_match(/@py_doc/, inspect_str)
      refute_match(/@py_nlp/, inspect_str)
      assert_match(/@text/, inspect_str)
    else
      # On older Ruby versions, just verify the method is defined
      assert_equal [:@text], doc.instance_variables_to_inspect
    end
  end

  def test_span_to_s
    doc = NLP_SM.read("Hello world!")
    span = doc[0..1]
    assert_equal "Hello world", span.to_s
    assert_equal span.text, span.to_s
  end

  # ============================
  # Doc#linguistic_summary
  # ============================

  def test_linguistic_summary_default
    doc = NLP_SM.read("Apple Inc. was founded by Steve Jobs.")
    summary = doc.linguistic_summary
    parsed = JSON.parse(summary)

    assert_instance_of Hash, parsed
    assert_equal "Apple Inc. was founded by Steve Jobs.", parsed["text"]
    assert_instance_of Array, parsed["tokens"]
    assert parsed["tokens"].length > 0
    # Default token_attributes: :text, :lemma, :pos, :dep, :head
    first_token = parsed["tokens"].first
    assert first_token.key?("text")
    assert first_token.key?("lemma")
    assert first_token.key?("pos")
    assert first_token.key?("dep")
    assert first_token.key?("head")
    assert_instance_of Array, parsed["entities"]
    assert_instance_of Array, parsed["noun_chunks"]
    # :sentences not included by default
    refute parsed.key?("sentences")
  end

  def test_linguistic_summary_custom_sections
    doc = NLP_SM.read("This is a test. Here is another sentence.")
    summary = doc.linguistic_summary(sections: [:text, :sentences])
    parsed = JSON.parse(summary)

    assert parsed.key?("text")
    assert parsed.key?("sentences")
    assert_instance_of Array, parsed["sentences"]
    assert_equal 2, parsed["sentences"].length
    refute parsed.key?("tokens")
    refute parsed.key?("entities")
  end

  def test_linguistic_summary_custom_token_attributes
    doc = NLP_SM.read("Hello world")
    summary = doc.linguistic_summary(
      sections: [:tokens],
      token_attributes: [:text, :tag, :morphology]
    )
    parsed = JSON.parse(summary)

    first_token = parsed["tokens"].first
    assert first_token.key?("text")
    assert first_token.key?("tag")
    assert first_token.key?("morphology")
    assert_instance_of Hash, first_token["morphology"]
    refute first_token.key?("lemma")
    refute first_token.key?("pos")
  end

  def test_linguistic_summary_entities_contain_labels
    doc = NLP_SM.read("Mr. Best flew to New York on Saturday morning.")
    summary = doc.linguistic_summary(sections: [:entities])
    parsed = JSON.parse(summary)

    assert parsed["entities"].length > 0
    parsed["entities"].each do |ent|
      assert ent.key?("text")
      assert ent.key?("label")
      assert_instance_of String, ent["label"]
    end
  end

  # ============================
  # OpenAIHelper (API key not required)
  # ============================

  def test_with_openai_yields_helper
    ENV.stub :[], ->(key) { key == "OPENAI_API_KEY" ? "dummy-key" : nil } do
      NLP_SM.with_openai do |helper|
        assert_instance_of Spacy::OpenAIHelper, helper
        assert_equal "gpt-5-mini", helper.model
      end
    end
  end

  def test_with_openai_returns_block_value
    ENV.stub :[], ->(key) { key == "OPENAI_API_KEY" ? "dummy-key" : nil } do
      result = NLP_SM.with_openai { |_ai| 42 }
      assert_equal 42, result
    end
  end

  def test_openai_helper_requires_api_key
    original = ENV["OPENAI_API_KEY"]
    begin
      ENV["OPENAI_API_KEY"] = nil
      assert_raises(RuntimeError, /OPENAI_API_KEY/) do
        Spacy::OpenAIHelper.new
      end
    ensure
      ENV["OPENAI_API_KEY"] = original
    end
  end

  # ============================
  # OpenAI integration (API key required)
  # ============================

  def test_with_openai_chat_basic
    result = NLP_SM.with_openai do |ai|
      ai.chat(user: "Say 'hello' and nothing else.")
    end
    assert_instance_of String, result
    assert result.length > 0
  end

  def test_with_openai_chat_with_linguistic_summary
    doc = NLP_SM.read("Apple Inc. was founded by Steve Jobs in California.")
    result = NLP_SM.with_openai do |ai|
      ai.chat(
        system: "You are a linguistic analyst. Respond with a brief analysis.",
        user: doc.linguistic_summary
      )
    end
    assert_instance_of String, result
    assert result.length > 0
  end

  def test_with_openai_with_pipe
    texts = ["The bank approved the loan.", "I sat on the river bank."]
    results = NLP_SM.with_openai do |ai|
      NLP_SM.pipe(texts).map do |doc|
        ai.chat(
          system: "Identify the meaning of 'bank' in one word.",
          user: doc.linguistic_summary
        )
      end
    end
    assert_instance_of Array, results
    assert_equal 2, results.length
    results.each { |r| assert_instance_of String, r }
  end

  def test_with_openai_embeddings
    result = NLP_SM.with_openai do |ai|
      ai.embeddings("Hello world")
    end
    assert_instance_of Array, result
    assert result.length > 0
  end

  def test_with_openai_chat_schema
    schema = {
      type: "object",
      properties: { greeting: { type: "string" } },
      required: ["greeting"],
      additionalProperties: false
    }
    result = NLP_SM.with_openai do |ai|
      ai.chat(user: "Greet me in one word.", schema: schema)
    end
    assert_instance_of Hash, result
    assert_instance_of String, result["greeting"]
  end

  # ============================
  # LLM providers (API key not required)
  # ============================

  def test_with_llm_openai_yields_openai_helper
    ENV.stub :[], ->(key) { key == "OPENAI_API_KEY" ? "dummy-key" : nil } do
      NLP_SM.with_llm(provider: :openai) do |helper|
        assert_instance_of Spacy::OpenAIHelper, helper
      end
    end
  end

  def test_with_llm_anthropic_yields_anthropic_helper
    NLP_SM.with_llm(provider: :anthropic, access_token: "dummy-key") do |helper|
      assert_instance_of Spacy::AnthropicHelper, helper
      assert_equal Spacy::AnthropicClient::DEFAULT_MODEL, helper.model
    end
  end

  def test_with_llm_ollama_needs_no_api_key
    ENV.stub :[], ->(_key) { nil } do
      NLP_SM.with_llm(provider: :ollama, model: "llama3.2") do |helper|
        assert_instance_of Spacy::OpenAIHelper, helper
        assert_equal "llama3.2", helper.model
      end
    end
  end

  def test_with_llm_unknown_provider_raises
    assert_raises(ArgumentError) do
      NLP_SM.with_llm(provider: :nonexistent) { |_helper| }
    end
  end

  def test_anthropic_helper_requires_api_key
    original = ENV["ANTHROPIC_API_KEY"]
    begin
      ENV["ANTHROPIC_API_KEY"] = nil
      assert_raises(RuntimeError, /ANTHROPIC_API_KEY/) do
        Spacy::AnthropicHelper.new
      end
    ensure
      ENV["ANTHROPIC_API_KEY"] = original
    end
  end

  def test_anthropic_embeddings_not_supported
    helper = Spacy::AnthropicHelper.new(access_token: "dummy-key")
    assert_raises(NotImplementedError) { helper.embeddings("Hello") }
  end

  # ============================
  # LLM clients against a local stub server (no network / API key)
  # ============================

  # Serves the given [status, body_hash] responses sequentially over HTTP.
  def with_stub_llm_server(responses)
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    thread = Thread.new do
      responses.each do |status, body|
        client = server.accept
        content_length = 0
        while (line = client.gets)
          break if line == "\r\n"

          content_length = line.split(":", 2)[1].to_i if line.downcase.start_with?("content-length")
        end
        client.read(content_length) if content_length.positive?
        json = body.to_json
        client.write("HTTP/1.1 #{status} X\r\nContent-Type: application/json\r\n" \
                     "Content-Length: #{json.bytesize}\r\nConnection: close\r\n\r\n#{json}")
        client.close
      end
    end
    yield port
  ensure
    thread&.join(2)
    server&.close
  end

  def test_openai_client_custom_base_url
    chat_response = { "choices" => [{ "message" => { "content" => "hello from stub" } }] }
    with_stub_llm_server([[200, chat_response]]) do |port|
      client = Spacy::OpenAIClient.new(access_token: "dummy",
                                       base_url: "http://127.0.0.1:#{port}/v1")
      response = client.chat(model: "stub-model", messages: [{ role: "user", content: "hi" }])
      assert_equal "hello from stub", response.dig("choices", 0, "message", "content")
    end
  end

  def test_openai_client_retries_without_temperature_on_rejection
    error_response = { "error" => { "message" => "Unsupported parameter: 'temperature' is not supported." } }
    chat_response = { "choices" => [{ "message" => { "content" => "ok" } }] }
    with_stub_llm_server([[400, error_response], [200, chat_response]]) do |port|
      client = Spacy::OpenAIClient.new(access_token: "dummy",
                                       base_url: "http://127.0.0.1:#{port}/v1")
      response = nil
      capture_io do
        response = client.chat(model: "stub-model", temperature: 0.7,
                               messages: [{ role: "user", content: "hi" }])
      end
      assert_equal "ok", response.dig("choices", 0, "message", "content")
    end
  end

  def test_anthropic_client_custom_base_url
    api_response = { "content" => [{ "type" => "text", "text" => "claude stub" }], "stop_reason" => "end_turn" }
    with_stub_llm_server([[200, api_response]]) do |port|
      client = Spacy::AnthropicClient.new(access_token: "dummy",
                                          base_url: "http://127.0.0.1:#{port}/v1")
      response = client.messages(model: "stub-model", messages: [{ role: "user", content: "hi" }])
      assert_equal "claude stub", response["content"][0]["text"]
    end
  end

  def test_anthropic_helper_warns_on_truncation_and_returns_nil_for_invalid_json
    api_response = { "content" => [{ "type" => "text", "text" => '{"incomplete":' }],
                     "stop_reason" => "max_tokens" }
    with_stub_llm_server([[200, api_response]]) do |port|
      helper = Spacy::AnthropicHelper.new(access_token: "dummy",
                                          base_url: "http://127.0.0.1:#{port}/v1")
      result = :unset
      _out, err = capture_io do
        result = helper.chat(user: "hi", schema: { type: "object" })
      end
      assert_nil result
      assert_match(/truncated/, err)
      assert_match(/not valid JSON/, err)
    end
  end

  def test_openai_helper_warns_on_truncation_and_returns_nil_for_invalid_json
    chat_response = { "choices" => [{ "finish_reason" => "length",
                                      "message" => { "content" => '{"incomplete":' } }] }
    with_stub_llm_server([[200, chat_response]]) do |port|
      helper = Spacy::OpenAIHelper.new(access_token: "dummy",
                                       base_url: "http://127.0.0.1:#{port}/v1")
      result = :unset
      _out, err = capture_io do
        result = helper.chat(user: "hi", schema: { type: "object" })
      end
      assert_nil result
      assert_match(/truncated/, err)
      assert_match(/not valid JSON/, err)
    end
  end

  # ============================
  # Anthropic integration (ANTHROPIC_API_KEY required)
  # ============================

  def test_with_llm_anthropic_chat
    skip "ANTHROPIC_API_KEY not set" unless ENV["ANTHROPIC_API_KEY"]

    result = NLP_SM.with_llm(provider: :anthropic) do |ai|
      ai.chat(user: "Say 'hello' and nothing else.")
    end
    assert_instance_of String, result
    assert result.length > 0
  end

  def test_with_llm_anthropic_chat_schema
    skip "ANTHROPIC_API_KEY not set" unless ENV["ANTHROPIC_API_KEY"]

    schema = {
      type: "object",
      properties: { greeting: { type: "string" } },
      required: ["greeting"],
      additionalProperties: false
    }
    result = NLP_SM.with_llm(provider: :anthropic) do |ai|
      ai.chat(user: "Greet me in one word.", schema: schema)
    end
    assert_instance_of Hash, result
    assert_instance_of String, result["greeting"]
  end

end
