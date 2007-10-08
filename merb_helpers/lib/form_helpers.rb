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
      
      def form_for(obj, &block)
        concat("<form>", block.binding)
        self.instance_eval do
          @obj = instance_variable_get("@#{obj}")
          @object_name = obj
          @block = block
          block.call
        end
        concat("</form>", block.binding)        
      end
      
      def text_control(col)
        concat("<input type='text' name='#{@object_name}[#{col}]' value='#{@obj.send(col)}'/>", @block.binding)
      end
      
    end
  end
end

class Merb::ViewContext
  include Merb::Helpers::Form
end