Gem::Specification.new do |s|
  s.name = %q{merb-laszlo}
  s.version = "0.5.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yehuda Katz"]
  s.autorequire = %q{merb-laszlo}
  s.date = %q{2008-05-23}
  s.description = %q{Merb plugin that provides support for Laszlo}
  s.email = %q{wycats@gmail.com}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["LICENSE", "README", "Rakefile", "lib/merb-laszlo", "lib/merb-laszlo/controllers.rb", "lib/merb-laszlo/helpers.rb", "lib/merb-laszlo/merbtasks.rb", "lib/merb-laszlo.rb", "spec/controllers", "spec/controllers/laszlo_controller.rb", "spec/laszlo_module_spec.rb", "spec/merb_laszlo_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://merb-plugins.rubyforge.org/merb-laszlo/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Merb plugin that provides support for Laszlo}

  s.add_dependency(%q<merb-core>, [">= 0.9.0"])
end
