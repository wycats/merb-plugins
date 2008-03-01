require "rake"
require 'fileutils'

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

gems = %w[merb_activerecord merb_datamapper merb_helpers merb_sequel merb_param_protection merb_rspec merb_test_unit]

orm_gems = %w[merb_activerecord merb_datamapper merb_sequel]

desc "Install it all"
task :install => "install:gems"

namespace :install do
  desc "Install the merb-plugins sub-gems"
  task :gems do
    gems.each do |dir|
      sh %{cd #{dir}; #{SUDO} rake install}
    end
  end

  desc "Install the ORM merb-pluging sub-gems"
  task :orm do
    orm_gems.each do |dir|
      sh %{cd #{dir}; #{SUDO} rake install}
    end
  end
end


desc "Bundle up all the merb-plugins gems"
task :bundle do
  mkdir_p "bundle"
  gems.each do |gem|
    File.open("#{gem}/Rakefile") do |rakefile|
      rakefile.read.detect {|l| l =~ /^VERSION\s*=\s*"(.*)"$/ }
      sh %{cd #{gem} ;  rake package ; cd ..}
      sh %{cp #{gem}/pkg/#{gem}-#{$1}.gem bundle/}
    end
  end
end