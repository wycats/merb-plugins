require "rake"
require 'fileutils'

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

gems = %w[merb_activerecord merb_datamapper merb_helpers merb_sequel merb_param_protection merb_rspec merb_test_unit]

desc "Install it all"
task :install => :install_gems

desc "Install the merb-plugins sub-gems"
task :install_gems do
  gems.each do |dir|
    sh %{cd #{dir}; #{SUDO} rake install}
  end
end
