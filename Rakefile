begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
  task :test => :spec
  task :deploy do
    sh "git push heroku master"
  end
rescue
# nothing
end
