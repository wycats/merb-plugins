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
    
    def lz_window(width = nil, height = nil, opts = {}, &blk)
      mrg = {:resizable => true}
      mrg.merge!(:width => width) if width
      mrg.merge!(:height => height) if height
      opts = mrg.merge(opts)
      tag(:window, nil, opts, &blk)
    end
    
    def add_lz_resource(src)
      @lz_resources ||= []
      @lz_resources << src unless URI.parse(src).scheme
    end
    
    def lz_resource(name, src, opts = {})
      add_lz_resource(src)
      opts.merge!(:name => name, :src => src)
      self_closing_tag(:resource, opts)
    end
    
    def lz_on(name, options = {}, *args, &blk)
      options.merge!(:name => "on#{name}")
      options.merge!(:args => args.map {|x| x.to_s}.join(", ")) unless args.empty?
      tag(:handler, capture(&blk), options)
    end
    
    def lz_attr(name, value, type = nil)
      mrg = {:name => name, :value => value}
      mrg.merge!(:type => type) if type
      self_closing_tag(:attribute, mrg)
    end

    def lz_def(name, *args, &blk)
      tag(:method, blk ? capture(&blk) : "", :name => name, :args => args.map {|x| x.to_s}.join(","))
    end
    
    def lz_view(width, height, bgcolor, options = {}, &blk)
      tag(:view, blk ? capture(&blk) : "", {:width => width, :height => height, :bgcolor => bgcolor}.merge(options))
    end
    
    def lz_resource_view(src, options = {}, &blk)
      add_lz_resource(src)
      tag(:view, blk ? capture(&blk) : "", {:resource => src}.merge(options))
    end
  
  end
end