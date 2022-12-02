### from acnh/datasheet/src/date_day_time.rb

require 'date'

### my timestamp format (orig in willow)

# daystamp for uniq dir name
def letter_of_the_week(num) 'nmtwrfs'.chars[num % 7] || "" end
def date_day_time(dt=DateTime.now)
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("%Y%m%d#{alpha}-%H%M")
end
def daystamp(dt=DateTime.now) date_day_time(dt)[2..-1] end
def daysubsq(dt=DateTime.now)
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("-%H%M#{alpha}")
end
# full date_day_time: /\d\d\d\d\d\d[nmtwrfs]-\d\d\d\d/
# shorter daystamp: /\d\d\d\d\d\d\d\d[nmtwrfs]-\d\d\d\d/
# subsq on the same day: /-\d\d\d\d[nmtwrfs]/

# add parse back to dt!!!

### prev

=begin 
# expects to receive integer, 0 for sun
def letter_of_the_week(num) 'nmtwrfs'.chars[num % 7] || "" end
###alias_method :day_letter, :letter_of_the_week

# [8] pry(main)> dt = DateTime.now
# => Wed, 07 Apr 2021 16:15:28 -0400
# [13] pry(main)> date_day_time(dt)
# => "20210407w-1615"

def date_day_time(dt=DateTime.now)
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("%Y%m%d#{alpha}-%H%M")
end

def cal_stamp(dt=DateTime.now) date_day_time(dt)[2..-1] end

# def cal_day(dt=DateTime.now) 'nmtwrfs'.chars[dt.wday % 7] end
# def cal_date_full(dt=DateTime.now) 
# 	dt.strftime("%Y%m%d#{cal_day(dt)}-%H%M")
# end
# def cal_date(dt=DateTime.now) cal_date_full(dt)[2..-1] end

### add parse back to dt!!!
=begin

=begin
# from willow
def letter_of_the_week(num) ["n", "m", "t", "w", "r", "f", "s"][num % 7] || "" end
# def letter_of_the_week(num) ["", "m", "t", "w", "r", "f", "s", "n"][num] || "" end

def stamp
	"<p>Timestamp: #{format_timestamp(Time.now)}</p>"
end

def format_timestamp(dt)
	#Time.now.strftime("%d/%m/%Y %H:%M")
	#d = DateTime.now
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("%Y%m%d#{alpha}-%H%M")
end

# where to put json files??? gen timestamped ../data-json- dir!!!
def format_timestamp(dt)
	#Time.now.strftime("%d/%m/%Y %H:%M")
	#d = DateTime.now
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("%Y%m%d#{alpha}-%H%M")
end

def letter_of_the_week(num)
	# counting from monday=1
	case num
	when 1
		"m"
	when 2
		"t"
	when 3
		"w"
	when 4
		"r"
	when 5
		"f"
	when 6
		"s"
	when 7
		"n"
	else
		""
	end
end

=end