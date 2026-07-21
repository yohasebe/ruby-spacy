# Change Log

## 0.5.0 - 2026-07-21
### Added
- `Language#with_llm(provider:)` — provider-neutral block-based LLM API
  supporting `:openai`, `:anthropic` (Claude), and `:ollama` (local models)
- `AnthropicHelper` / `AnthropicClient` — Anthropic Messages API support
  using only net/http (default model: `claude-opus-4-8`; requires
  `ANTHROPIC_API_KEY`)
- `base_url:` option for OpenAI client/helper — works with any
  OpenAI-compatible server (Ollama, LM Studio, llama.cpp server, vLLM,
  OpenRouter, etc.)
- `schema:` option for `chat` — Structured Outputs on both providers;
  returns a validated, parsed Ruby Hash
- New examples under `examples/llm/` (Anthropic, local Ollama, and a
  spaCy-vs-LLM NER comparison with structured outputs)

### Changed
- `temperature` is now sent only when explicitly specified; if a model
  rejects it, the request is retried once without it. The model-name
  heuristic (`temperature_unsupported?`) has been removed, so new models
  work without gem updates. Note: previously a default of 0.7 was sent to
  models that supported it (also from `Doc#openai_query` /
  `Doc#openai_completion`); now the API default applies unless you pass
  `temperature:` yourself
- Shared HTTP layer (`LLMClientBase`) extracted from `OpenAIClient`;
  no behavior change for existing OpenAI usage

## 0.4.1 - 2026-07-19
### Fixed
- Gem packaging: normalize file permissions at build time so packaged files
  are world-readable (0644 / 0755). Version 0.4.0 shipped 11 owner-only
  (0600) files, which made the gem unusable after `sudo gem install`

## 0.4.0 - 2026-02-23
### Added
- `Language#with_openai` block API with `OpenAIHelper` for streamlined OpenAI integration
- `Doc#linguistic_summary` for JSON-formatted spaCy analysis output
- `Token#idx`, `Span#text`/`Span#to_s`, `Language#memory_zone` (spaCy 3.8+)

### Fixed
- `Doc#ents` returns proper `Span` objects instead of raw Python objects

### Changed
- Model name validation in `Language#initialize` for security
- OpenAI client: temperature support for o-series models, 429 retry with
  exponential backoff, client reuse, `dimensions`/`response_format` parameters,
  tool call depth limit
- Improved `respond_to_missing?` across all wrapper classes
- Added `instance_variables_to_inspect` for Ruby 4.0+ compatibility
- Added `base64` gem dependency (required for Ruby 3.4+)

## 0.3.0 - 2025-01-06
### Added
- Ruby 4.0 support
- `Doc#to_bytes` for serializing documents to binary format
- `Doc.from_bytes` for restoring documents from binary data
- `PhraseMatcher` class for efficient phrase matching
- `Language#phrase_matcher` helper method

### Changed
- Replaced `ruby-openai` gem with custom `OpenAIClient` implementation
- Updated default OpenAI model to `gpt-5-mini`
- Updated embeddings model to `text-embedding-3-small`
- Changed `max_tokens` parameter to `max_completion_tokens` (backward compatible)
- Added `fiddle` gem dependency (required for Ruby 4.0)

## 0.2.4 - 2024-12-11
### Changed
- Timeout and retry feature for `Spacy::Language.new`

## 0.2.3 - 2024-08-27
- Timeout option added to `Spacy::Language.new`
- Default OpenAI models updated to `gpt-4o-mini`

## 0.2.0 - 2022-10-02
### Added
- spaCy 3.7.0 supported
- `Doc#openai_query`
- `Doc#openai_completion`
- `Doc#openai_embeddings`

## 0.1.4.1 - 2021-07-06
- Test code refined
- `Spacy::Language::most_similar` returns an array of hash-based objects that accepts method calls

## 0.1.4 - 2021-06-26
### Added
- `Spacy::Lexeme` class

- `Spacy::Token#morpheme` method 
## 0.1.3 - 2021-06-26
- Code cleanup

## 0.1.2 - 2021-06-26
### Added
- `Spacy::Token#morpheme` method 

## 0.1.1 - 2021-06-26
- Project description fixed

## 0.1.0 - 2021-06-26
- Initial release
