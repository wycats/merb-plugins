if defined?(Merb::Plugins)
  autoload :DataMapper, File.join(File.dirname(__FILE__) / "merb_datamapper" / "autoconnect")
  
  Merb::Plugins.add_rakefiles "merb_datamapper" / "merbtasks"
end