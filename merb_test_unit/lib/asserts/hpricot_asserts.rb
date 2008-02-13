# http://yehudakatz.com/2007/01/27/a-better-assert_select-assert_elements/
# based on assert_elements
# Author: Yehuda Katz
# Email:  wycats @nospam@ gmail.com
# Web:    http://www.yehudakatz.com
#
# which was based on HpricotTestHelper
# Author: Luke Redpath
# Email: contact @nospam@ lukeredpath.co.uk
# Web: www.lukeredpath.co.uk / opensource.agileevolved.com

module Merb::Test::Unit::HpricotAsserts
  include Test::Unit::Assertions
  include Merb::Test::HpricotHelper
  
  def assert_elements(css_query, output = nil, equality = {}, &block)
    message = equality.delete(:message) if equality.is_a?(Hash)

    case equality
      when Numeric then equality = {:count => equality}
      when Range then equality = {:minimum => equality.to_a.first, :maximum => equality.to_a.last }
      else equality ||= {}
    end
    
    equality.merge!({:minimum => 1}) if (equality.keys & [:minimum, :maximum, :count]).empty?
    
    els = get_elements(css_query, equality[:text], output)

    ret = equality.keys.include?(:minimum) ? (els.size >= equality[:minimum]) : true 
    ret &&= (els.size <= equality[:maximum]) if equality.keys.include?(:maximum)
    ret &&= (els.size == equality[:count]) if equality.keys.include?(:count)
    
    if block && !els.empty?
      ret &&= self.dup.instance_eval do
        @output = HpricotTestHelper::DocumentOutput.new(els.inner_html)
        @block = true 
        instance_eval(&block)
      end
    end
    
    if(equality[:count] != 0)
      assert ret, "#{ message } \"#{ css_query }\" with \"#{ equality.inspect }\" was not found."
    else
      assert ret, "#{ message } \"#{ css_query }\" with \"#{ equality.reject{|k,v| k == :count}.inspect }\" was found, but you specified :count => 0."
    end
    ret
  end
end