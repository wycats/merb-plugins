require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "merb_activerecord"
NAME = "merb_activerecord"
VERSION = "0.5"
AUTHOR = "Duane Johnson"
EMAIL = "canadaduane@gmail.com"
HOMEPAGE = "http://merbivore.com"
SUMMARY = "Merb plugin that provides ActiveRecord support for Merb"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.4.0')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs,activerecord_generators}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERSION}}
end

task :release => :package do
  sh %{rubyforge add_release merb #{PLUGIN} #{VERSION} pkg/#{NAME}-#{VERSION}.gem}
end
