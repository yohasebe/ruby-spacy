# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

# Gem packaging preserves on-disk file modes; owner-only permissions here
# produce gems whose files are unreadable after a sudo install. Executable
# status is determined by path alone because local (Dropbox-synced) modes
# are unreliable.
task :normalize_permissions do
  `git ls-files -z`.split("\x0").each do |f|
    executable = f.start_with?("bin/", "exe/")
    File.chmod(executable ? 0o755 : 0o644, f)
  end
end

Rake::Task["build"].enhance([:normalize_permissions])
