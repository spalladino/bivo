# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.


unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks

vendored_cucumber_bin = Dir["#{Rails.root}/vendor/{gems,plugins}/cucumber*/bin/cucumber"].first
$LOAD_PATH.unshift(File.dirname(vendored_cucumber_bin) + '/../lib') unless vendored_cucumber_bin.nil?

begin
  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({:ok => ['db:test:prepare','cucumber:load_seed_data']}, 'Run features that should pass') do |t|
      t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'default'
    end

    Cucumber::Rake::Task.new({:wip => 'db:test:prepare'}, 'Run features that are being worked on') do |t|
      t.binary = vendored_cucumber_bin
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'wip'
    end

    Cucumber::Rake::Task.new({:rerun => 'db:test:prepare'}, 'Record failing features and run only them if any exist') do |t|
      t.binary = vendored_cucumber_bin
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'rerun'
    end

    desc 'Run all features'
    task :all => [:ok, :wip]
    
    task :load_seed_data => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
  desc 'Alias for cucumber:ok'
  task :cucumber => 'cucumber:ok'

  task :default => :cucumber

  task :features => :cucumber do
    STDERR.puts "*** The 'features' task is deprecated. See rake -T cucumber ***"
  end
  
  task :cucumber_steps_list do
    step_definition_dir = "../bivo/features"

    f = File.new("cucumber_steps.htm", "w")

    f << "<table><th>Regex</th><th>Modifiers</th><th>Step Definition Args</th><th>Source file</th>"

    Dir.glob(File.join(step_definition_dir,'**/*.rb')).each do |step_file|
      File.new(step_file).read.each_line do |line|
        next unless line =~ /^\s*(?:Given|When|Then)\s+\//
        matches = /(?:Given|When|Then)\s*\/(.*)\/([imxo]*)\s*do\s*(?:$|\|(.*)\|)/.match(line).captures
        matches << step_file
        f << "<tr>"
        f << "<td>#{matches[0]}</td>"
        f << "<td>#{matches[1]}</td>"
        f << "<td>#{matches[2]}</td>"
        f << "<td><a href=\"#{matches[3]}\">#{matches[3]}</a></td>"
        f << "</tr>"
      end
    end

    f << "</table>"
  end
  
rescue LoadError
  desc 'cucumber rake task not available (cucumber not installed)'
  task :cucumber do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end

end
