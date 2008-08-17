module Ordinalize
  # Ordinalize turns a number into an ordinal string used to denote the
  # position in an ordered sequence such as 1st, 2nd, 3rd, 4th.
  #
  # Examples
  #   1.ordinalize     # => "1st"
  #   2.ordinalize     # => "2nd"
  #   1002.ordinalize  # => "1002nd"
  #   1003.ordinalize  # => "1003rd"
  def ordinalize
    if (11..13).include?(self % 100)
      "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

Integer.send :include, Ordinalize

# Time.now.to_ordinalized_s :long
# => "February 28th, 2006 21:10"
module OrdinalizedFormatting
  
  def self.extended(obj)
    include Merb::Helpers::DateAndTime
  end
  
  def to_ordinalized_s(format = :default)
    format = Merb::Helpers::DateAndTime.date_formats[format] 
    return self.to_s if format.nil?
    strftime_ordinalized(format)
  end

  # Gives you a relative date in an attractive format
  #
  # ==== Parameters
  # format<String>:: strftime string used to formatt a time/date object
  # locale<String, Symbol>:: An optional value which can be used by localization plugins
  #
  # ==== Returns
  # String:: Ordinalized time/date object
  #
  # ==== Examples
  #    5.days.ago.strftime_ordinalized('%b %d, %Y')     # => 
  def strftime_ordinalized(fmt, format=nil)
    strftime(fmt.gsub(/(^|[^-])%d/, '\1_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
  end
end