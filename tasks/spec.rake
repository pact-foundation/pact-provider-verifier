require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec:first') do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = '--tag ~run_separately'
end

RSpec::Core::RakeTask.new('spec:second') do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = '--tag run_separately'
end


task :spec => ['spec:first', 'spec:second']
