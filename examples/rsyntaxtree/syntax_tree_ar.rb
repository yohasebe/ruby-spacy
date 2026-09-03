# frozen_string_literal: true

# Arabic via an external pipeline. spaCy ships no trained pipeline for
# Arabic (or any other right-to-left language), so this example builds one
# with Stanza through spacy-stanza. These are NOT ruby-spacy dependencies;
# install them yourself first:
#
#   pip install spacy-stanza
#   pip install --upgrade "stanza>=1.10"   # spacy-stanza's stanza pin is old and conflicts with current torch
#   python -c "import stanza; stanza.download('ar')"
#
# Note: at exit, spacy-stanza under PyCall prints a harmless
# multiprocessing.resource_tracker LoadError to stderr (sys.executable
# points to ruby, not python); the results are unaffected.

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "fileutils"

# Requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree

py_nlp = PyCall.import_module("spacy_stanza")
               .load_pipeline("ar", processors: "tokenize,pos,lemma,depparse", verbose: false)
nlp = Spacy::Language.new(py_nlp: py_nlp)
doc = nlp.read("قرأ الطالب الجديد كتابا مثيرا في المكتبة أمس.")

puts doc.syntax_tree

# Right-to-left languages are drawn mirrored automatically (pass
# mirror: "off" to disable)
output_dir = File.join(File.dirname(__FILE__), "outputs")
FileUtils.mkdir_p(output_dir)
File.binwrite(File.join(output_dir, "tree_ar_projection.png"),
              doc.syntax_tree(format: :png))
