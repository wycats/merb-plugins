load File.dirname(__FILE__) / "form" / "helpers.rb"
load File.dirname(__FILE__) / "form" / "builder.rb"

class Merb::Controller
  class_inheritable_accessor :_form_class
  include Merb::Helpers::Form
end

Merb::BootLoader.after_app_loads do
  class Merb::Controller
    self._form_class =
      Object.full_const_get(Merb::Plugins.config[:helpers][:form_class]) rescue Merb::Helpers::Form::Builder::ResourcefulFormWithErrors
  end
end
