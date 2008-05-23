module Merb
  module GlobalHelpers

    def lz(name, *args, &blk)
      send("lz_#{name}", *args, &blk)
    end
  
    def lz_reload_button
      contents = "Reload" +
      tag(:handler, %{LzBrowser.loadJS("window.location = \\\"#{request.full_uri}\\\"")}, :name => "onclick") +
      tag(:handler, %{this.bringToFront()}, :name => "oninit")
      
      tag(:button, contents, :valign => "bottom", :align => "right")
    end

    def lz_class(name, extends = nil, opts = {}, &blk)
      opts.merge!(:name => name)
      opts.merge!(:extends => extends) if extends
      tag(:class, nil, opts, &blk)
    end
  
    def lz_text(text, opts = {})
      self_closing_tag(:text, {:text => text}.merge(opts))
    end
    
    def lz_window(width, height, opts = {}, &blk)
      opts = {:resizable => true, :width => width, :height => height}.merge!(opts)
      tag(:window, nil, opts, &blk)
    end
    
    def lz_resource(name, src, opts = {})
      @lz_resources ||= []
      @lz_resources << src
      opts.merge!(:name => name, :src => src)
      self_closing_tag(:resource, opts)
    end
    
    def lz_on(name, options = {}, *args, &blk)
      options.merge!(:name => "on#{name}")
      options.merge!(:args => args.map {|x| x.to_s}.join(", ")) unless args.empty?
      tag(:handler, capture(&blk), options)
    end
  
  end
end