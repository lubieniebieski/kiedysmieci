require "./main"
Dir.glob("lib/tasks/*.rake").each { |r| load r }
require "rspec/core"
require "rspec/core/rake_task"

task default: :spec

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)
