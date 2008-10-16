require File.join(File.dirname(__FILE__), "merb_parts", "part_controller")
require File.join(File.dirname(__FILE__), "merb_parts", "mixins", "parts_mixin")

Merb::Controller.send(:include, Merb::PartsMixin)