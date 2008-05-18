require File.dirname(__FILE__) + '/spec_helper'
require 'merb_helpers'
Merb.load_dependencies :environment => "test"

include Merb::Helpers::DateAndTime
include Merb::ControllerMixin

describe "Date" do
  before :each do
    @date = Date.new(2007, 11, 10)
  end

  it "Should do to_time conversion and return a Time class" do
    @date.is_a?Date
    @date.to_time.is_a?Time
  end

  it "Should do to_time conversion to utc by default" do
    @date.to_time.to_s.should == 'Sat Nov 10 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to utc when param :utc is given" do
    @date.to_time(:utc).to_s.should == 'Sat Nov 10 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to local time when param :local is given" do
    pending("Needs to have the call to figure out the local time stubbed so this test will work no matter what your local TZ is.")
    @date.to_time(:local).to_s.should == 'Sat Nov 10 00:00:00 -0500 2007'
  end

  it "Should return itself when to_date is called" do
    @date.to_date.should == @date
  end
end

describe "TimeDSL" do
  it "Should do second/seconds" do
    10.seconds.should == 10
    1.second.should == 1
  end

  it "Should do minute/minutes" do
    22.minutes.should == 22 * 60
    1.minute.should == 60
  end

  it "Should do hour/hours" do
    24.hours.should == 24 * 3600
    1.hour.should == 3600
  end

  it "Should do day/days" do
    7.days.should == 7 * 24 * 3600
    1.day.should == 24 * 3600
  end

  it "Should do month/months" do
    9.months.should == 9 * 30 * 24 * 3600
    1.month.should == 30 * 24 * 3600
  end

  it "Should do year/years" do
    3.years.should == 3 * 364.25 * 24 * 3600
    1.year.should == 364.25 * 24 * 3600
  end

  it "Should do ago/until" do
    5.seconds.ago.should be_close(Time.now - 5, 0.5)
    8.minutes.until(3.minute.from_now).should be_close(3.minutes.from_now - 8 * 60, 0.5)
  end

  it "Should do from_now/since" do
    3.seconds.from_now.should be_close(Time.now + 3, 0.5)
    2.minutes.since(2.minutes.ago).should be_close(2.minutes.ago + 2 * 60, 0.5)
  end
end

describe "relative_date" do
  before :each do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 1, 11))
  end

  it "Should show today" do
    relative_date(Time.now.utc).should == "today"
  end

  it "Should show yesterday" do
    relative_date(1.day.ago.utc).should == 'yesterday'
  end

  it "Should show tomorrow" do
    relative_date(1.day.from_now.utc).should == 'tomorrow'
  end

  it "Should show date with year" do
    relative_date(Time.utc(2005, 11, 15)).should == 'Nov 15th, 2005'
  end

  it "Should show date" do
    relative_date(Time.utc(2007, 11, 15)).should == 'Nov 15th'
  end
end

describe "relative_date_span" do
  before :each do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 1, 11))
  end

  it "Should show date span on the same day" do
    relative_date_span([Time.utc(2007, 11, 15), Time.utc(2007, 11, 15)]).should == 'Nov 15th'
  end

  it "Should show date span on the same day on different year" do
    relative_date_span([Time.utc(2006, 11, 15), Time.utc(2006, 11, 15)]).should == 'Nov 15th, 2006'
  end

  it "Should show date span on the same month" do
    relative_date_span([Time.utc(2007, 11, 15), Time.utc(2007, 11, 16)]).should == 'Nov 15th - 16th'
    relative_date_span([Time.utc(2007, 11, 16), Time.utc(2007, 11, 15)]).should == 'Nov 15th - 16th'
  end

  it "Should show date span on the same month on different year" do
    relative_date_span([Time.utc(2006, 11, 15), Time.utc(2006, 11, 16)]).should == 'Nov 15th - 16th, 2006'
    relative_date_span([Time.utc(2006, 11, 16), Time.utc(2006, 11, 15)]).should == 'Nov 15th - 16th, 2006'
  end

  it "Should show date span on the different month" do
    relative_date_span([Time.utc(2007, 11, 15), Time.utc(2007, 12, 16)]).should == 'Nov 15th - Dec 16th'
    relative_date_span([Time.utc(2007, 12, 16), Time.utc(2007, 11, 15)]).should == 'Nov 15th - Dec 16th'
  end

  it "Should show date span on the different month on different year" do
    relative_date_span([Time.utc(2006, 11, 15), Time.utc(2006, 12, 16)]).should == 'Nov 15th - Dec 16th, 2006'
    relative_date_span([Time.utc(2006, 12, 16), Time.utc(2006, 11, 15)]).should == 'Nov 15th - Dec 16th, 2006'
  end

  it "Should show date span on the different year" do
    relative_date_span([Time.utc(2006, 11, 15), Time.utc(2007, 12, 16)]).should == 'Nov 15th, 2006 - Dec 16th, 2007'
    relative_date_span([Time.utc(2007, 12, 16), Time.utc(2006, 11, 15)]).should == 'Nov 15th, 2006 - Dec 16th, 2007'
  end
end

describe "relative_time_span" do
  before :each do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 1, 11))
  end

  # Time, Single Date
  it "Should show time span on the same day with same time" do
    relative_time_span([Time.utc(2007, 11, 15, 17, 00, 00)]).should == '5:00 PM Nov 15th'
  end

  it "Should show time span on the same day with same time on different year" do
    relative_time_span([Time.utc(2006, 11, 15, 17, 0), Time.utc(2006, 11, 15, 17, 0)]).should == '5:00 PM Nov 15th, 2006'
  end

  it "Should show time span on the same day with different times in same half of day" do
    relative_time_span([Time.utc(2007, 11, 15, 10), Time.utc(2007, 11, 15, 11, 0)]).should == '10:00 - 11:00 AM Nov 15th'
  end

  it "Should show time span on the same day with different times in different half of day" do
    relative_time_span([Time.utc(2007, 11, 15, 10, 0), Time.utc(2007, 11, 15, 14, 0)]).should == '10:00 AM - 2:00 PM Nov 15th'
  end

  it "Should show time span on the same day with different times in different half of day in different year" do
    relative_time_span([Time.utc(2006, 11, 15, 10, 0), Time.utc(2006, 11, 15, 14, 0)]).should == '10:00 AM - 2:00 PM Nov 15th, 2006'
  end

  it "Should show time span on different days in same year" do
    relative_time_span([Time.utc(2006, 11, 15, 10, 0), Time.utc(2006, 12, 16, 14, 0)]).should == '10:00 AM Nov 15th - 2:00 PM Dec 16th, 2006'
  end

  it "Should show time span on different days in different years" do
    relative_time_span([Time.utc(2006, 11, 15, 10, 0), Time.utc(2007, 12, 16, 14, 0)]).should == '10:00 AM Nov 15th, 2006 - 2:00 PM Dec 16th, 2007'
  end

  it "Should show time span on different days in current year" do
    relative_time_span([Time.utc(2007, 11, 15, 10, 0), Time.utc(2007, 12, 16, 14, 0)]).should == '10:00 AM Nov 15th - 2:00 PM Dec 16th'
  end
end

describe "time_lost_in_words" do
  it "Should show seconds" do
    time_lost_in_words(Time.now, Time.now, true).should == "less than 5 seconds"
  end

  it "Should not show seconds" do
    time_lost_in_words(Time.now).should == "less than a minute"
  end

  it "Should do minutes" do
    time_lost_in_words(2.minutes.ago).should == "2 minutes"
  end

  it "Should do hour" do
    time_lost_in_words(50.minutes.ago).should == "about 1 hour"
  end

  it "Should do hours" do
    time_lost_in_words(2.hours.ago).should == "about 2 hours"
  end

  it "Should do day" do
    time_lost_in_words(1.day.ago).should == "1 day"
  end

  it "Should do days" do
    time_lost_in_words(5.days.ago).should == "5 days"
  end

  it "Should do month" do
    time_lost_in_words(1.month.ago).should == "about 1 month"
  end

  it "Should do months" do
    time_lost_in_words(5.months.ago).should == "5 months"
  end

  it "Should do year" do
    time_lost_in_words(1.2.years.ago).should == "about 1 year"
  end

  it "Should do years" do
    time_lost_in_words(5.5.years.ago).should == "over 5 years"
  end
end

describe "prettier_time" do
  # prettier time"
  it "Should not show leading zero in hour" do
    prettier_time(Time.utc(2007, 11, 15, 14, 0)).should == '2:00 PM'
  end

  it "Should convert to 12 hour time" do
    prettier_time(Time.utc(2007, 11, 15, 2, 0)).should == '2:00 AM'
  end

  it "Should handle midnight correctly" do
    prettier_time(Time.utc(2007, 11, 15, 0, 0)).should == '12:00 AM'
  end
end

describe "to_ordinalized_s" do

  before(:each) do
    @date = Date.parse('2008-5-3')
    @time = Time.parse('2008-5-3 14:00')
  end

  it "should render a date using #to_s if no format is passed" do
    @date.to_ordinalized_s.should == @date.to_s
  end

  it "should render a time using #to_s if no format is passed" do
    @time.to_ordinalized_s.should == @time.to_s
  end

  it "should render a date or time using the db format" do
    @date.to_ordinalized_s(:db).should == "2008-05-03 00:00:00"
    @time.to_ordinalized_s(:db).should == "2008-05-03 14:00:00"
  end

  it "should render a date or time using the long format" do
    @date.to_ordinalized_s(:long).should == "May 3rd, 2008 00:00"
    @time.to_ordinalized_s(:long).should == "May 3rd, 2008 14:00"
  end

  it "should render a date or time using the time format" do
    @date.to_ordinalized_s(:time).should == "00:00"
    @time.to_ordinalized_s(:time).should == "14:00"
  end

  it "should render a date or a time using the short format" do
    @date.to_ordinalized_s(:short).should == "3rd May 00:00"
    @time.to_ordinalized_s(:short).should == "3rd May 14:00"
  end

end