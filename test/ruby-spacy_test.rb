# frozen_string_literal: true

require "test_helper"

class SpacyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Spacy::VERSION
  end

  # ============================
  # Doc related methods
  # ============================
  # Tests with a name having a "test_py" prefix uses spaCy methods
  # directly without a ruby wrapper method (hence not defined in ruby-spacy.rb)
  
  def setup
    @nlp = Spacy::Language.new
  end

  def test_doc_each
    doc = @nlp.read("Hello everybody!")
    assert_equal doc.class.name, "Spacy::Doc"
    doc.each do |token|
      assert_equal token.class.name, "Spacy::Token"
    end
  end

  def test_doc_slice
    doc = @nlp.read("Give it back! He pleaded.")
    assert_equal doc[0].class.name, "Spacy::Token"
    assert_equal doc[0..-1].class.name, "Spacy::Span"
    assert_equal doc[0].text, "Give"
    assert_equal doc[-1].text, "."
  end

  def test_doc_span
    doc = @nlp.read("Give it back! He pleaded.")
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
    doc = @nlp.read("Give it back!")
    results = []
    doc.each do |token|
      results << token.text
    end
    assert_equal results, ["Give", "it", "back", "!"]
  end

  def test_doc_len
    doc = @nlp.read("Give it back!")
    assert_equal doc.count, 4
    assert_equal doc.length, 4
    assert_equal doc.size, 4
    assert_equal doc.len, 4
  end

  def test_doc_py_char_span
    doc = @nlp.read("I like New York")
    span = doc.char_span(7, 15, label = "GPE")
    assert_equal span.text, "New York"
    assert_equal span.label_, "GPE"
  end

  def test_doc_similarity
    @nlp = Spacy::Language.new("en_core_web_lg")
    apples = @nlp.read("I like apples")
    oranges = @nlp.read("I like oranges")
    apples_oranges = apples.similarity(oranges)
    oranges_apples = oranges.similarity(apples)
    assert_equal apples_oranges, oranges_apples
  end

  def test_doc_retokenize
    doc = @nlp.read("I like David Bowie")
    attrs = {LEMMA: "David Bowie"}
    doc.retokenize(2, 4, attrs = attrs)
    assert_equal doc[2].text, "David Bowie"
    assert_equal doc[2].lemma_, "David Bowie"
  end

  def test_doc_retokenize_split
    doc = @nlp.read("I live in NewYork")
    pos_in_doc = 3
    head_pos_in_split = 1
    ancestor_pos = 2
    attributes = {POS: ["PROPN", "PROPN"],
                  DEP: ["pobj", "compound"]}
    doc.retokenize_split(pos_in_doc, ["New", "York"], head_pos_in_split, ancestor_pos, attributes)
    assert_equal doc.tokens.collect(&:text).join(" "), "I live in New York"
    assert_equal doc.tokens[3].head.text, "York"
    assert_equal doc.tokens[4].head.text, "in"
  end

  def test_doc_noun_chunks
    doc = @nlp.read("A phrase with another phrase occurs.")
    chunks = doc.noun_chunks
    assert_equal chunks.size, 2
    assert_equal chunks[0].text, "A phrase"
    assert_equal chunks[1].text, "another phrase"
  end

  def test_doc_sents
    doc = @nlp.read("This is a sentence. Here's another.")
    sents = doc.sents
    assert_equal sents.size, 2
    assert_equal sents.collect{|s|s.root.text}, ["is", "'s"]
  end

  def test_doc_ents
    doc = @nlp.read("Mr. Best flew to New York on Saturday morning.")
    ents = doc.ents
    assert_equal ents[0].label_, "PERSON"
    assert_equal ents[0].text, "Best"
  end

  def test_doc_py_has_vector
    doc = @nlp.read("I like apples")
    assert doc.has_vector
  end

  def test_doc_py_vector
    nlp = Spacy::Language.new("en_core_web_lg")
    doc = nlp.read("I like apples")
    assert_equal doc.vector.dtype, "float32"
    assert_equal doc.vector.shape.to_s, "(300,)"
  end

  # ============================
  # Language related methods
  # ============================

  def test_language_disable_pipes
    nlp = Spacy::Language.new
    nlp.select_pipes(disable: ["tagger", "parser"])
    nlp.initialize
    assert_empty ["tagger", "parser"] - nlp.disabled
    assert_empty ["senter"] - @nlp.disabled
  end

  def test_get_lexeme
    nlp = Spacy::Language.new
    king = nlp.get_lexeme("king")
    assert_equal king.text, "king"
  end

  def test_most_similar
    nlp = Spacy::Language.new("en_core_web_lg")
    tokyo = nlp.get_lexeme("Tokyo")
    japan = nlp.get_lexeme("Japan")
    france = nlp.get_lexeme("France")
    query = tokyo.vector - japan.vector + france.vector
    result = nlp.most_similar(query, 10)
    assert result.collect{|r|r[:text]}.index("Paris")
  end

  # ============================
  # Span related methods
  # ============================
  # Tests with a name having a "test_py" prefix uses spaCy methods
  # directly without a ruby wrapper method (hence not defined in ruby-spacy.rb)

  def test_span_each
    doc = @nlp.read("Hello everybody!")
    span = doc[0 .. -1]
    assert_equal span.class.name, "Spacy::Span"
    span.each do |token|
      assert_equal token.class.name, "Spacy::Token"
    end
  end

  def test_span_slice
    doc = @nlp.read("Give it back! He pleaded.")
    span1 = doc[0 .. 3]
    span2 = doc.span(0 .. 3)
    span3 = doc[0 ... 4]
    span4 = doc.span(0, 4)
    assert_equal span1.text, span2.text
    assert_equal span2.text, span3.text
    assert_equal span3.text, span4.text
  end

  def test_span_size
    doc = @nlp.read("Give it back! He pleaded.")
    span = doc[0 .. 3]
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
    doc = @nlp.read("Mr. Best flew to New York on Saturday morning.")
    ents = doc.span(0, 3).ents
    assert_equal ents[0].label_, "PERSON"
    assert_equal ents[0].text, "Best"
  end

  def test_span_sent
    doc = @nlp.read("Give it back! He pleaded.")
    assert_equal doc.span(0, 1).sent.text, "Give it back!"
  end

  def test_span_noun_chunks
    doc = @nlp.read("A phrase with another phrase occurs.")
    chunks = doc.span(2, 4).noun_chunks
    assert_equal chunks.size, 1
    assert_equal chunks[0].text, "another phrase"
  end

  def test_span_as_doc
    doc = @nlp.read("I like New York in Autumn.")
    span = doc[2 .. 5]
    doc2 = span.as_doc
    assert_equal doc2.class.name, "Spacy::Doc"
  end

  def test_span_py_root
    doc = @nlp.read("I like New York in Autumn.")
    root = doc.span(2, 5).root
    assert_equal root.text, "York"
  end

  def test_span_conjuncts
    doc = @nlp.read("I like apples and oranges")
    assert_equal doc.span(2, 1).conjuncts[0].text, "oranges"
  end

  def test_span_lefts
    doc = @nlp.read("I like New York in Autumn.")
    assert_equal doc.span(3, 1).lefts[0].text, "New"
    assert_equal doc.span(3, 1).n_lefts, 1
  end

  def test_span_rights
    doc = @nlp.read("I like New York in Autumn.")
    assert_equal doc.span(3, 1).rights[0].text, "in"
    assert_equal doc.span(3, 1).n_rights, 1
  end

  def test_span_subtree
    doc = @nlp.read("Give it back! He pleaded.")
    assert_equal doc.span(0 .. 3).subtree.size, 4
  end

  # ============================
  # Token related methods
  # ============================

  def test_token_subtree
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[3] # "York"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.subtree.map(&:text), ["New", "York", "in", "Autumn"] 
  end

  def test_token_ancestors
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[4] # "in"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.ancestors.map(&:text), ["York", "like"] 
  end

  def test_token_children
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[1] # "like"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.children.map(&:text), ["I", "York", "."] 
  end

  def test_token_lefts
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[1] # "like"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.lefts.map(&:text), ["I"] 
  end

  def test_token_rights
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[1] # "like"
    assert_equal token.class.name, "Spacy::Token"
    assert_equal token.rights.map(&:text), ["York", "."] 
  end

  def test_token_rights
    doc = @nlp.read("I like New York in Autumn.")
    token = doc[-1]
    assert_equal "#{token}", "."
  end

  def test_token_morph
    doc = @nlp.read("I like New York in Autumn.")
    token1 = doc[1]  # like
    token2 = doc[-2] # Autumn
    assert_equal token1.morphology["Tense"], "Pres"
    assert_equal token1.morphology["VerbForm"], "Fin"
    assert_equal token2.morphology(false), "NounType=Prop|Number=Sing"
  end

  def test_token_method_missing
    doc = @nlp.read("I like New York in Autumn.")
    tokens = doc.tokens
    selected = tokens.select do |t|
      !t.is_stop
    end
    assert_equal selected.map(&:text), ["like", "New", "York", "Autumn", "."]
  end

  # ============================
  # Matcher related methods
  # ============================

  def test_matcher_match
    matcher = @nlp.matcher
    matcher.add("US_PRESIDENT", [[{lower: "barack"}, {lower: "obama"}]])

    doc = @nlp.read("Barack Obama was the 44th president of the United States")

    match = matcher.match(doc).first

    span = Spacy::Span.new(doc, start_index: match[:start_index], end_index: match[:end_index], options: {label: match[:match_id]})
    assert_equal span.text, "Barack Obama"
    assert_equal span.label_, "US_PRESIDENT"
  end

end
