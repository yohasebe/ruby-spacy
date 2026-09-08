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

# Inspect the built gem before it can be pushed: its payload must match
# spec.files in both directions, and must carry no secrets, machine-local
# paths, or owner-only modes. `release` depends on `build`, so this is the
# last thing that runs before a push.
Rake::Task["build"].enhance { sh "ruby", "scripts/verify_gem.rb" }
