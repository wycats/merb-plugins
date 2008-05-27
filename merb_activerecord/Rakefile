require 'rubygems'
require 'rake/gempackagetask'
require 'merb-core/tasks/merb_rake_helper'

NAME = "merb_activerecord"
GEM_VERSION = "0.9.4"
AUTHOR = "Duane Johnson"
EMAIL = "canadaduane@gmail.com"
HOMEPAGE = "http://merbivore.com/"
SUMMARY = "Merb plugin that provides ActiveRecord support for Merb"

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'merb'
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency("merb-core", ">= 0.9.4")
  s.require_path = "lib"
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs,activerecord_generators}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install merb_activerecord"
task :install => :package do
  sh %{#{sudo} gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION} --no-rdoc --no-ri --no-update-sources}
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{sudo} jruby -S gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri}
  end

end