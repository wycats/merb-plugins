class Hash
  
  def to_html_attributes
    map do |k,v|
      "#{k.to_s.camelize.downcase}=\"#{v}\""
    end.join(" ")
  end
  
  def add_html_class!(html_class)
    if self[:class]
      self[:class] = "#{self[:class]} #{html_class}"
    else
      self[:class] = html_class
    end
  end
  
end

module Merb
  module Helpers
    module Form
    
      def error_messages_for(obj, error_li = nil, html_class='submittal_failed')
        return "" unless obj.errors
        header_message = block_given? ? yield(obj.errors) : "<h2>Form submittal failed because of #{obj.errors.size} problems</h2>"
        ret = %Q{
          <div class='#{html_class}'>
            #{header_message}
            <ul>
        }
        obj.errors.each {|err| ret << (error_li ? error_li.call(err) : "<li>#{err[0]} #{err[1]}</li>") }
        ret << %Q{
            </ul>
          </div>
        }
      end
      
      def open_tag(name, attrs = nil)
        "<#{name}#{' ' + attrs.to_html_attributes if attrs}>"
      end
      
      def self_closing_tag(name, attrs = nil)
        "<#{name}#{' ' + attrs.to_html_attributes if attrs}/>"
      end
      
      def form_tag(attrs = {}, &block)
        concat(open_tag("form", attrs), block.binding)
        concat(capture(&block), block.binding)
        concat("</form>", block.binding)
      end
      
      def form_for(obj, attrs=nil, &block)
        concat(open_tag("form", attrs), block.binding)
        fields_for(obj, attrs, &block)
        concat("</form>", block.binding)
      end
      
      def fields_for(obj, attrs=nil, &block)
        old_obj, @_obj = @_obj, instance_variable_get("@#{obj}")
        @_object_name = obj
        old_block, @_block = @_block, block
        
        concat(capture(&block), block.binding)

        @_obj, @_block = old_obj, old_block        
      end
      
      def name_value(col, attrs)
        {:name => "#{@_object_name}[#{col}]", :value => "#{@_obj.send(col)}"}.merge(attrs)
      end
      
      def text_control(col, attrs = {})
        errorify_field(attrs, col)
        text_field(name_value(col, attrs))
      end
      
      def text_field(attrs = {})
        attrs.merge!(:type => "text")
        self_closing_tag("input", attrs)
      end
      
      def checkbox_control(col, attrs = {})
        errorify_field(attrs, col)
        val = @_obj.send(col)
        attrs.merge!(:value => val ? "1" : "0")
        attrs.merge!(:checked => "checked") if val
        checkbox_field(name_value(col, attrs))
      end
      
      def checkbox_field(attrs = {})
        attrs.merge!(:type => :checkbox)
        attrs.add_html_class!("checkbox")
        self_closing_tag("input", attrs)
      end
      
      def hidden_control(col, attrs = {})
        errorify_field(attrs, col)
        hidden_field(name_value(col, attrs))
      end
      
      def hidden_field(attrs = {})
        attrs.merge!(:type => :hidden)
        self_closing_tag("input", attrs)
      end
      
      def radio_group_control(col, options = {}, attrs = {})
        errorify_field(attrs, col)
        val = @_obj.send(col)
        ret = ""
        options.each do |opt|
          hash = {:name => "#{@_object_name}[#{col}]", :value => opt}
          hash.merge!(:selected => "selected") if val.to_s == opt.to_s
          ret << radio_field(hash)
        end
        ret
      end
      
      def radio_field(attrs = {})
        attrs.merge!(:type => "radio")
        attrs.add_html_class!("radio")
        self_closing_tag("input", attrs)
      end
      
      def submit_button(contents, attrs = {})
        attrs.merge!(:type => "submit")
        open_tag("button", attrs) + contents + "</button>"
      end

      def errorify_field(attrs, col)
        attrs.add_html_class!("error") if !@obj.valid? && @obj.errors.on(col)
      end
      
    end
  end
end

class Merb::ViewContext
  include Merb::Helpers::Form
end