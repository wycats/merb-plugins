module Merb
  module TagHelpers
    # Concat will concatenate text directly to the buffer of the template.
    # The binding must be supplied in order to obtian the buffer.  This can be called directly in the 
    # template as 
    # concat( "text", binding )
    #
    # or from a helper method that accepts a block as
    # concat( "text", block.binding )
    def concat( string, binding )
      _buffer( binding ) << string
    end
    
    # Creates a generic HTML tag. You can invoke it a variety of ways.
    #   
    #   tag :div
    #   # <div></div>
    #   
    #   tag :div, 'content'
    #   # <div>content</div>
    #   
    #   tag :div, :class => 'class'
    #   # <div class="class"></div>
    #   
    #   tag :div, 'content', :class => 'class'
    #   # <div class="class">content</div>
    #   
    #   tag :div do
    #     'content'
    #   end
    #   # <div>content</div>
    #   
    #   tag :div, :class => 'class' do
    #     'content'
    #   end
    #   # <div class="class">content</div>
    # 
    def tag(name, contents = nil, attrs = {}, &block)
      attrs = contents if contents.is_a?(Hash)
      contents = capture(&block) if block_given?
      open_tag(name, attrs) + contents.to_s + close_tag(name)
    end
    
    # Creates the opening tag with attributes for the provided +name+
    # attrs is a hash where all members will be mapped to key="value"
    #
    # Note: This tag will need to be closed
    def open_tag(name, attrs = nil)
      "<#{name}#{' ' + attrs.to_html_attributes if attrs && !attrs.empty?}>"
    end
    
    # Creates a closing tag
    def close_tag(name)
      "</#{name}>"
    end
    
    # Creates a self closing tag.  Like <br/> or <img src="..."/>
    #
    # +name+ : the name of the tag to create
    # +attrs+ : a hash where all members will be mapped to key="value"
    def self_closing_tag(name, attrs = nil)
      "<#{name}#{' ' + attrs.to_html_attributes if attrs && !attrs.empty?}/>"
    end
    
    
    # Provides direct acccess to the buffer for this view context
    def _buffer( the_binding )
      @_buffer = eval( "_buf", the_binding )
    end
    
    # Capture allows you to extract a part of the template into an 
    # instance variable. You can use this instance variable anywhere
    # in your templates and even in your layout. 
    # 
    # Example of capture being used in a .herb page:
    # 
    #   <% @foo = capture do %>
    #     <p>Some Foo content!</p> 
    #   <% end %>
    def capture(*args, &block)
      # execute the block
      begin
        buffer = _buffer( block.binding )
      rescue
        buffer = nil
      end
    
      if buffer.nil?
        capture_block(*args, &block)
      else
        capture_erb_with_buffer(buffer, *args, &block)
      end
    end
    
    private
      def capture_block(*args, &block)
        block.call(*args)
      end
    
      def capture_erb(*args, &block)
        buffer = _buffer
        capture_erb_with_buffer(buffer, *args, &block)
      end
    
      def capture_erb_with_buffer(buffer, *args, &block)
        pos = buffer.length
        block.call(*args)
    
        # extract the block 
        data = buffer[pos..-1]
    
        # replace it in the original with empty string
        buffer[pos..-1] = ''
    
        data
      end
    
      def erb_content_for(name, &block)
        controller.thrown_content[name] << capture_erb( &block )
      end
    
      def block_content_for(name, &block)
        controller.thrown_content[name] << capture_block( &block )
      end
    
  end
end

class Merb::Controller #:nodoc:
  include Merb::TagHelpers
end    