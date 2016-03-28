require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)

task :ac do
  Rake::Task['rubocop:auto_correct'].invoke
end

task all: [:rubocop]

task default: [:all]
