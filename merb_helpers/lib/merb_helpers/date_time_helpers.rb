
# Everything above here has pretty much been implemented in the assistance gem...

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

  def strftime_ordinalized(fmt)
    strftime(fmt.gsub(/(^|[^-])%d/, '\1_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
  end
end

class Date
  include OrdinalizedFormatting
  # Converts a Date instance to a Time, where the time is set to the beginning of the day.
  # The timezone can be either :local or :utc (default :utc).
  #
  # ==== Examples:
  #   date = Date.new(2007, 11, 10)  # => Sat, 10 Nov 2007
  #
  #   date.to_time                   # => Sat Nov 10 00:00:00 0800 2007
  #   date.to_time(:local)           # => Sat Nov 10 00:00:00 0800 2007
  #
  #   date.to_time(:utc)             # => Sat Nov 10 00:00:00 UTC 2007
  def to_time(form = :utc)
    ::Time.send("#{form}_time", year, month, day)
  end
  def to_date; self; end
end

class Time
  include OrdinalizedFormatting
  # Ruby 1.8-cvs and 1.9 define private Time#to_date
  %w(to_date to_datetime).each do |method|
    public method if private_instance_methods.include?(method)
  end
  def to_time; self; end
end

module Merb
  module Helpers
    # Provides a number of methods for displaying and dealing with dates and times
    #
    # Parts were strongly based on http://ar-code.svn.engineyard.com/plugins/relative_time_helpers/, and
    # active_support
    #
    # The key methods are `relative_date`, `relative_date_span`, and `relative_time_span`.  This also gives
    # you the Rails style Time DSL for working with numbers eg. 3.months.ago or 5.days.until(1.year.from_now)
    module DateAndTime
      @@time_class = Time
      @@time_output = {
        :today          => 'today',
        :yesterday      => 'yesterday',
        :tomorrow       => 'tomorrow',
        :initial_format => '%b %d',
        :year_format    => ', %Y'
      }
      @@date_formats = {
        :db           => "%Y-%m-%d %H:%M:%S",
        :time         => "%H:%M",
        :short        => "%d %b %H:%M",
        :long         => "%B %d, %Y %H:%M",
        :long_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y %H:%M") },
        :rfc822       => "%a, %d %b %Y %H:%M:%S %z"
      }
      
      def self.time_class
        @@time_class
      end
      
      def time_output
        @@time_output
      end
      
      def date_formats
        @@date_formats
      end
      
      # Gives you a relative date in an attractive format
      #
      # ==== Parameters
      # time<~to_date>:: The Date or Time to test
      #
      # ==== Returns
      # String:: The sexy relative date
      #
      # ==== Examples
      #   relative_date(Time.now.utc) => "today"
      #   relative_date(5.days.ago) => "March 5th"
      #   relative_date(1.year.ago) => "March 10th, 2007"
      def relative_date(time)
        date  = time.to_date
        today = DateAndTime.time_class.now.to_date
        if date == today
          DateAndTime.time_output[:today]
        elsif date == (today - 1)
          DateAndTime.time_output[:yesterday]
        elsif date == (today + 1)
          DateAndTime.time_output[:tomorrow]
        else
          fmt  = DateAndTime.time_output[:initial_format].dup
          fmt << DateAndTime.time_output[:year_format] unless date.year == today.year
          time.strftime_ordinalized(fmt)
        end
      end
      
      # Gives you a relative date span in an attractive format
      #
      # ==== Parameters
      # times<~first,~last>:: The Dates or Times to test
      #
      # ==== Returns
      # String:: The sexy relative date span
      #
      # ==== Examples
      #   relative_date([1.second.ago, 10.seconds.ago]) => "March 10th"
      #   relative_date([1.year.ago, 1.year.ago) => "March 10th, 2007"
      #   relative_date([Time.now, 1.day.from_now]) => "March 10th - 11th"
      #   relative_date([Time.now, 1.year.ago]) => "March 10th, 2007 - March 10th, 2008"
      def relative_date_span(times)
        times = [times.first, times.last].collect! { |t| t.to_date }
        times.sort!
        if times.first == times.last
          relative_date(times.first)
        else
          first = times.first; last = times.last; now = DateAndTime.time_class.now
          arr = [first.strftime_ordinalized('%b %d')]
          arr << ", #{first.year}" unless first.year == last.year
          arr << ' - '
          arr << last.strftime('%b') << ' ' unless first.year == last.year && first.month == last.month
          arr << last.day.ordinalize
          arr << ", #{last.year}" unless first.year == last.year && last.year == now.year
          arr.to_s
        end
      end
      
      # Gives you a relative date span in an attractive format
      #
      # ==== Parameters
      # times<~first,~last>:: The Dates or Times to test
      #
      # ==== Returns
      # String:: The sexy relative time span
      #
      # ==== Examples
      #   relative_time_span([1.second.ago, 10.seconds.ago]) => "12:00 - 12:09 AM March 10th"
      #   relative_time_span([1.year.ago, 1.year.ago) => "12:09 AM March 10th, 2007"
      #   relative_time_span([Time.now, 13.hours.from_now]) => "12:09 AM - 1:09 PM March 10th"
      #   relative_time_span([Time.now, 1.year.ago]) => "12:09 AM March 10th, 2007 - 12:09 AM March 10th, 2008"
      def relative_time_span(times)
        times = [times.first, times.last].collect! { |t| t.to_time }
        times.sort!
        if times.first == times.last
          "#{prettier_time(times.first)} #{relative_date(times.first)}"
        elsif times.first.to_date == times.last.to_date
            same_half = (times.first.hour/12 == times.last.hour/12)
            "#{prettier_time(times.first, !same_half)} - #{prettier_time(times.last)} #{relative_date(times.first)}"
      
        else
          first = times.first; last = times.last; now = DateAndTime.time_class.now        
          arr = [prettier_time(first)]
          arr << ' '
          arr << first.strftime_ordinalized('%b %d')
          arr << ", #{first.year}" unless first.year == last.year
          arr << ' - '
          arr << prettier_time(last)
          arr << ' '
          arr << last.strftime('%b') << ' ' unless first.year == last.year && first.month == last.month
          arr << last.day.ordinalize
          arr << ", #{last.year}" unless first.year == last.year && last.year == now.year
          arr.to_s
        end
      end
      
      # Condenses time... very similar to time_ago_in_words in ActionPack
      #
      # ==== Parameters
      # from_time<~to_time>:: The Date or Time to start from
      # to_time<~to_time>:: The Date or Time to go to, Defaults to Time.now.utc
      # include_seconds<Boolean>:: Count the seconds initially, Defaults to false
      #
      # ==== Returns
      # String:: The time distance
      #
      # ==== Examples
      # time_lost_in_words(3.minutes.from_now)           # => 3 minutes
      # time_lost_in_words(Time.now - 15.hours)          # => 15 hours
      # time_lost_in_words(Time.now, 3.minutes.from_now) # => 3 minutes
      # time_lost_in_words(Time.now)                     # => less than a minute
      # time_lost_in_words(Time.now, Time.now, true)     # => less than 5 seconds
      #
      def time_lost_in_words(from_time, to_time = Time.now.utc, include_seconds = false)
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round
      
        case distance_in_minutes
          when 0..1
            return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
            case distance_in_seconds
              when 0..4   then 'less than 5 seconds'
              when 5..9   then 'less than 10 seconds'
              when 10..19 then 'less than 20 seconds'
              when 20..39 then 'half a minute'
              when 40..59 then 'less than a minute'
              else             '1 minute'
            end
      
          when 2..44           then "#{distance_in_minutes} minutes"
          when 45..89          then 'about 1 hour'
          when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
          when 1440..2879      then '1 day'
          when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
          when 43200..86399    then 'about 1 month'
          when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
          when 525600..1051199 then 'about 1 year'
          else                      "over #{(distance_in_minutes / 525600).round} years"
        end
      end
      alias :time_ago_in_words :time_lost_in_words
      
      def prettier_time(time, ampm=true)
        time.strftime("%I:%M#{" %p" if ampm}").sub(/^0/, '')
      end
    end
  end
end

class Merb::Controller 
  include Merb::Helpers::DateAndTime
end
