# frozen_string_literal: true

task check_command: :environment do |_task, args|
  command, message, alt_command = args.to_a
  puts "Running: #{command}"
  unless system(command)
    system(alt_command) if alt_command
    message ||= "Command '#{command}' failed."
    raise message
  end
end

task check: :environment do
  repo_dir = Rails.root.join("..").expand_path
  Dir.chdir(repo_dir) do
    Rake::Task["check_command"].execute([
      "! git grep --no-index -I '[^ -~]' -- $( git ls-files --others --exclude-standard; git ls-files )",
      "Non-ASCII characters found."
    ])
  end

  rails_dir = Rails.root
  Dir.chdir(rails_dir) do
    Rake::Task["check_command"].execute(["bundle exec rubocop -A --fail-level=A", "RuboCop found issues."])
    Rake::Task["check_command"].execute(["bundle exec rspec", "RSpec tests failed."])
    coverage = JSON.parse(File.read("coverage/.last_run.json")).dig("result", "line")
    raise "Test coverage is #{coverage}%, which is below 100%." if coverage != 100

    Rake::Task["check_command"].execute([
      "bundle exec erb_lint --fail-level=I app/**/*.{html,text,js}{+*,}.erb",
      "ERB Lint found issues.", "bundle exec erb_lint -a app/**/*.{html,text,js}{+*,}.erb"
    ])
  end
end
