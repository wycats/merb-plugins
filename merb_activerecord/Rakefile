require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "merb_activerecord"
NAME = "merb_activerecord"
VERSION = "0.9.4"
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
  s.add_dependency("merb-core", ">= 0.9.4")
  s.require_path = "lib"
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs,activerecord_generators}/**/*")
end

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install merb_activerecord"
task :install => :package do
  sh %{#{SUDO} gem install pkg/#{NAME}-#{VERSION} --no-rdoc --no-ri --no-update-sources}
end

desc "Release the current version on rubyforge"
task :release => :package do
  sh %{rubyforge add_release merb #{PLUGIN} #{VERSION} pkg/#{NAME}-#{VERSION}.gem}
end
