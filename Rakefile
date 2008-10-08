## THESE ARE CRUCIAL
module Merb
  # Set this to the version of merb-core that you are building against/for
  VERSION = "0.9.8"

  # Set this to the version of merb-more you plan to release
  MORE_VERSION = "0.9.8"
end

GEM_VERSION = Merb::VERSION

require 'rubygems'
require "rake/clean"
require "rake/gempackagetask"
require 'merb-core/tasks/merb_rake_helper'
require 'fileutils'
include FileUtils


gems = %w[merb_activerecord merb_sequel merb_param_protection merb_test_unit merb_stories merb_screw_unit merb_exceptions]

# Implement standard Rake::GemPackageTask tasks - see merb.thor
task :clobber_package do; FileUtils.rm_rf('pkg'); end
task :package do; end

desc "Uninstall all gems"
task :uninstall => :uninstall_gems

desc "Build the merb-more gems"
task :build_gems do
  gems.each do |dir|
    Dir.chdir(dir) { sh "#{Gem.ruby} -S rake package" }
  end
end

desc "Install the merb-plugins sub-gems"
task :install_gems do
  gems.each do |dir|
    Dir.chdir(dir) { sh "#{Gem.ruby} -S rake install" }
  end
end

desc "Uninstall the merb-plugins sub-gems"
task :uninstall_gems do
  gems.each do |dir|
    Dir.chdir(dir) { sh "#{Gem.ruby} -S rake uninstall" }
  end
end

desc "Clobber the merb-plugins sub-gems"
task :clobber_gems do
  gems.each do |dir|
    Dir.chdir(dir) { sh "#{Gem.ruby} -S rake clobber" }
  end
end

desc "Bundle up all the merb-plugins gems"
task :bundle do
  mkdir_p "bundle"
  gems.each do |gem|
    File.open("#{gem}/Rakefile") do |rakefile|
      rakefile.read.detect {|l| l =~ /^GEM_VERSION\s*=\s*"(.*)"$/ }
      Dir.chdir(gem){ sh "rake package" }
      sh %{cp #{gem}/pkg/#{gem}-#{$1}.gem bundle/}
    end
  end
end

desc "Release gems in merb-plugins"
task :release do
  gems.each do |dir|
    Dir.chdir(dir){ sh "#{Gem.ruby} -S rake release" }
  end
end

desc "Run spec examples for Merb More gems, one by one."
task :spec do
  gems.each do |gem|
    Dir.chdir(gem) { sh "#{Gem.ruby} -S rake spec" }
  end
end

desc 'Default: run spec examples for all the gems.'
task :default => 'spec'