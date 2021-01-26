require "bundler/gem_tasks"

$: << File.join(File.dirname(__FILE__), "lib")

Dir.glob('./tasks/**/*.rake').each { |task| load task }

task :default => [:spec]
