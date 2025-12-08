note
	description: "[
		Simple Date - High-level wrapper over Eiffel's DATE class.

		Provides a fluent API for date manipulation with innovative features
		like business day calculations, relative date navigation, and
		multiple output formats.

		Design influences:
		- Pylon library: Multiple format outputs (to_iso, to_european, to_rfc)
		- ISO8601 library: Validation patterns
		- Modern datetime libraries: Fluent, immutable-style API

		Example:
			d := create {SIMPLE_DATE}.make (2025, 12, 7)
			next_week := d.plus_days (7)
			is_working := d.is_weekday
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DATE

inherit
	COMPARABLE
		redefine
			is_equal,
			out
		end

create
	make,
	make_now,
	make_from_string,
	make_from_date

convert
	to_date: {DATE}

feature {NONE} -- Initialization

	make (a_year, a_month, a_day: INTEGER)
			-- Create date from components.
		require
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
		do
			create internal_date.make (a_year, a_month, a_day)
		ensure
			year_set: year = a_year
			month_set: month = a_month
			day_set: day = a_day
		end

	make_now
			-- Create date with today's date.
		do
			create internal_date.make_now
		end

	make_from_string (a_string: STRING)
			-- Create date from string, trying common formats.
			-- Supports: YYYY-MM-DD, MM/DD/YYYY, DD.MM.YYYY, YYYYMMDD
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		local
			l_year, l_month, l_day: INTEGER
			l_parts: LIST [STRING]
			l_str: STRING
		do
			l_str := a_string.twin
			l_str.left_adjust
			l_str.right_adjust

			if l_str.count = 8 and then l_str.is_integer then
				-- YYYYMMDD format
				l_year := l_str.substring (1, 4).to_integer
				l_month := l_str.substring (5, 6).to_integer
				l_day := l_str.substring (7, 8).to_integer
			elseif l_str.has ('-') then
				-- YYYY-MM-DD (ISO format)
				l_parts := l_str.split ('-')
				if l_parts.count >= 3 then
					l_year := l_parts [1].to_integer
					l_month := l_parts [2].to_integer
					l_day := l_parts [3].to_integer
				end
			elseif l_str.has ('/') then
				-- MM/DD/YYYY (American format)
				l_parts := l_str.split ('/')
				if l_parts.count >= 3 then
					l_month := l_parts [1].to_integer
					l_day := l_parts [2].to_integer
					l_year := l_parts [3].to_integer
				end
			elseif l_str.has ('.') then
				-- DD.MM.YYYY (European format)
				l_parts := l_str.split ('.')
				if l_parts.count >= 3 then
					l_day := l_parts [1].to_integer
					l_month := l_parts [2].to_integer
					l_year := l_parts [3].to_integer
				end
			end

			-- Default to epoch if parsing failed
			if l_year = 0 then
				l_year := 1970
				l_month := 1
				l_day := 1
			end

			create internal_date.make (l_year, l_month, l_day)
		end

	make_from_date (a_date: DATE)
			-- Create from existing Eiffel DATE.
		require
			date_not_void: a_date /= Void
		do
			create internal_date.make_by_days (a_date.days)
		end

feature -- Access

	year: INTEGER
			-- Year component.
		do
			Result := internal_date.year
		end

	month: INTEGER
			-- Month component (1-12).
		do
			Result := internal_date.month
		end

	day: INTEGER
			-- Day of month component (1-31).
		do
			Result := internal_date.day
		end

	day_of_week: INTEGER
			-- Day of week (1=Monday, 7=Sunday per ISO 8601).
		do
			Result := internal_date.day_of_the_week
			-- Eiffel uses 1=Sunday, convert to ISO 8601 (1=Monday)
			Result := Result - 1
			if Result = 0 then
				Result := 7
			end
		ensure
			valid_range: Result >= 1 and Result <= 7
		end

	day_of_year: INTEGER
			-- Day of year (1-366).
		local
			l_jan1: DATE
		do
			create l_jan1.make (year, 1, 1)
			Result := internal_date.days - l_jan1.days + 1
		ensure
			valid_range: Result >= 1 and Result <= 366
		end

	week_of_year: INTEGER
			-- ISO 8601 week number (1-53).
		local
			l_days: INTEGER
		do
			-- Simplified ISO week calculation
			l_days := day_of_year + (day_of_week - 1)
			Result := (l_days - 1) // 7 + 1
			if Result < 1 then
				Result := 52
			elseif Result > 52 then
				Result := 1
			end
		ensure
			valid_range: Result >= 1 and Result <= 53
		end

	quarter: INTEGER
			-- Quarter of year (1-4).
		do
			Result := (month - 1) // 3 + 1
		ensure
			valid_range: Result >= 1 and Result <= 4
		end

feature -- Status

	is_leap_year: BOOLEAN
			-- Is current year a leap year?
		do
			Result := internal_date.is_leap_year (year)
		end

	is_weekend: BOOLEAN
			-- Is this date a weekend day (Saturday or Sunday)?
		do
			Result := day_of_week >= 6
		end

	is_weekday: BOOLEAN
			-- Is this date a weekday (Monday-Friday)?
		do
			Result := day_of_week <= 5
		end

	is_today: BOOLEAN
			-- Is this date today?
		local
			l_today: DATE
		do
			create l_today.make_now
			Result := internal_date.is_equal (l_today)
		end

	is_past: BOOLEAN
			-- Is this date in the past?
		local
			l_today: DATE
		do
			create l_today.make_now
			Result := internal_date < l_today
		end

	is_future: BOOLEAN
			-- Is this date in the future?
		local
			l_today: DATE
		do
			create l_today.make_now
			Result := internal_date > l_today
		end

feature -- Comparison

	is_before (other: SIMPLE_DATE): BOOLEAN
			-- Is this date before `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_date < other.internal_date
		end

	is_after (other: SIMPLE_DATE): BOOLEAN
			-- Is this date after `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_date > other.internal_date
		end

	is_less alias "<" (other: SIMPLE_DATE): BOOLEAN
			-- Is this date before `other'?
		do
			Result := internal_date < other.internal_date
		end

	is_equal (other: SIMPLE_DATE): BOOLEAN
			-- Is this date equal to `other'?
		do
			Result := internal_date.is_equal (other.internal_date)
		end

	days_between (other: SIMPLE_DATE): INTEGER
			-- Number of days between this date and `other'.
			-- Positive if `other' is after this date.
		require
			other_not_void: other /= Void
		do
			Result := other.internal_date.days - internal_date.days
		end

feature -- Arithmetic

	plus_days (a_days: INTEGER): SIMPLE_DATE
			-- New date with `a_days' added.
		local
			l_date: DATE
		do
			create l_date.make_by_days (internal_date.days + a_days)
			create Result.make_from_date (l_date)
		ensure
			result_attached: Result /= Void
		end

	minus_days (a_days: INTEGER): SIMPLE_DATE
			-- New date with `a_days' subtracted.
		do
			Result := plus_days (-a_days)
		ensure
			result_attached: Result /= Void
		end

	plus_weeks (a_weeks: INTEGER): SIMPLE_DATE
			-- New date with `a_weeks' added.
		do
			Result := plus_days (a_weeks * 7)
		ensure
			result_attached: Result /= Void
		end

	plus_months (a_months: INTEGER): SIMPLE_DATE
			-- New date with `a_months' added.
			-- Day is clamped to valid range for target month.
		local
			l_year, l_month, l_day: INTEGER
			l_max_day: INTEGER
		do
			l_year := year
			l_month := month + a_months

			-- Normalize month overflow
			if l_month > 12 then
				l_year := l_year + (l_month - 1) // 12
				l_month := ((l_month - 1) \\ 12) + 1
			elseif l_month < 1 then
				l_year := l_year + (l_month - 12) // 12
				l_month := 12 - ((-l_month) \\ 12)
				if l_month = 0 then
					l_month := 12
				end
			end

			-- Clamp day to valid range
			l_max_day := days_in_month_for (l_year, l_month)
			l_day := day.min (l_max_day)

			create Result.make (l_year, l_month, l_day)
		ensure
			result_attached: Result /= Void
		end

	minus_months (a_months: INTEGER): SIMPLE_DATE
			-- New date with `a_months' subtracted.
		do
			Result := plus_months (-a_months)
		ensure
			result_attached: Result /= Void
		end

	plus_years (a_years: INTEGER): SIMPLE_DATE
			-- New date with `a_years' added.
			-- Feb 29 becomes Feb 28 in non-leap years.
		local
			l_day: INTEGER
		do
			l_day := day
			-- Handle Feb 29 -> Feb 28 for non-leap years
			if month = 2 and day = 29 then
				if not internal_date.is_leap_year (year + a_years) then
					l_day := 28
				end
			end
			create Result.make (year + a_years, month, l_day)
		ensure
			result_attached: Result /= Void
		end

feature -- Business Days (Innovative!)

	plus_business_days (a_days: INTEGER): SIMPLE_DATE
			-- New date with `a_days' business days added (skipping weekends).
		local
			l_result: SIMPLE_DATE
			l_remaining: INTEGER
		do
			l_result := Current
			l_remaining := a_days

			from
			until
				l_remaining = 0
			loop
				l_result := l_result.plus_days (1)
				if l_result.is_weekday then
					l_remaining := l_remaining - 1
				end
			end

			Result := l_result
		ensure
			result_attached: Result /= Void
			is_weekday: a_days > 0 implies Result.is_weekday
		end

	business_days_until (other: SIMPLE_DATE): INTEGER
			-- Count of business days between this date and `other'.
		require
			other_not_void: other /= Void
		local
			l_current: SIMPLE_DATE
			l_end: SIMPLE_DATE
			l_count: INTEGER
			l_forward: BOOLEAN
		do
			if is_before (other) then
				l_current := Current
				l_end := other
				l_forward := True
			else
				l_current := other
				l_end := Current
				l_forward := False
			end

			from
			until
				l_current.is_equal (l_end)
			loop
				l_current := l_current.plus_days (1)
				if l_current.is_weekday then
					l_count := l_count + 1
				end
			end

			Result := l_count
			if not l_forward then
				Result := -Result
			end
		end

feature -- Navigation

	start_of_month: SIMPLE_DATE
			-- First day of this date's month.
		do
			create Result.make (year, month, 1)
		ensure
			result_attached: Result /= Void
			is_first: Result.day = 1
			same_month: Result.month = month
			same_year: Result.year = year
		end

	end_of_month: SIMPLE_DATE
			-- Last day of this date's month.
		do
			create Result.make (year, month, days_in_month)
		ensure
			result_attached: Result /= Void
			same_month: Result.month = month
			same_year: Result.year = year
		end

	start_of_year: SIMPLE_DATE
			-- First day of this date's year (January 1).
		do
			create Result.make (year, 1, 1)
		ensure
			result_attached: Result /= Void
			is_jan_1: Result.month = 1 and Result.day = 1
		end

	end_of_year: SIMPLE_DATE
			-- Last day of this date's year (December 31).
		do
			create Result.make (year, 12, 31)
		ensure
			result_attached: Result /= Void
			is_dec_31: Result.month = 12 and Result.day = 31
		end

	next_weekday (a_weekday: INTEGER): SIMPLE_DATE
			-- Next occurrence of `a_weekday' (1=Monday, 7=Sunday).
			-- If today is that weekday, returns next week.
		require
			valid_weekday: a_weekday >= 1 and a_weekday <= 7
		local
			l_days_ahead: INTEGER
		do
			l_days_ahead := a_weekday - day_of_week
			if l_days_ahead <= 0 then
				l_days_ahead := l_days_ahead + 7
			end
			Result := plus_days (l_days_ahead)
		ensure
			result_attached: Result /= Void
			correct_weekday: Result.day_of_week = a_weekday
			is_future: Result > Current
		end

	previous_weekday (a_weekday: INTEGER): SIMPLE_DATE
			-- Previous occurrence of `a_weekday' (1=Monday, 7=Sunday).
			-- If today is that weekday, returns last week.
		require
			valid_weekday: a_weekday >= 1 and a_weekday <= 7
		local
			l_days_back: INTEGER
		do
			l_days_back := day_of_week - a_weekday
			if l_days_back <= 0 then
				l_days_back := l_days_back + 7
			end
			Result := minus_days (l_days_back)
		ensure
			result_attached: Result /= Void
			correct_weekday: Result.day_of_week = a_weekday
			is_past: Result < Current
		end

feature -- Output (Multiple formats - influenced by Pylon)

	to_iso8601: STRING
			-- ISO 8601 format: "YYYY-MM-DD"
		do
			create Result.make (10)
			Result.append_integer (year)
			Result.append_character ('-')
			if month < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (month)
			Result.append_character ('-')
			if day < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (day)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 10
		end

	to_iso_compact: STRING
			-- Compact ISO format: "YYYYMMDD"
		do
			create Result.make (8)
			Result.append_integer (year)
			if month < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (month)
			if day < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (day)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 8
		end

	to_american: STRING
			-- American format: "MM/DD/YYYY"
		do
			create Result.make (10)
			if month < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (month)
			Result.append_character ('/')
			if day < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (day)
			Result.append_character ('/')
			Result.append_integer (year)
		ensure
			result_attached: Result /= Void
		end

	to_european: STRING
			-- European format: "DD.MM.YYYY"
		do
			create Result.make (10)
			if day < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (day)
			Result.append_character ('.')
			if month < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (month)
			Result.append_character ('.')
			Result.append_integer (year)
		ensure
			result_attached: Result /= Void
		end

	to_human: STRING
			-- Human-readable format: "December 7, 2025"
		do
			create Result.make (20)
			Result.append (month_name)
			Result.append_character (' ')
			Result.append_integer (day)
			Result.append_string (", ")
			Result.append_integer (year)
		ensure
			result_attached: Result /= Void
		end

	to_human_short: STRING
			-- Short human format: "Dec 7, 2025"
		do
			create Result.make (12)
			Result.append (month_name_short)
			Result.append_character (' ')
			Result.append_integer (day)
			Result.append_string (", ")
			Result.append_integer (year)
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation (ISO 8601).
		do
			Result := to_iso8601
		end

feature -- Month/Day Names

	month_name: STRING
			-- Full month name.
		do
			inspect month
			when 1 then Result := "January"
			when 2 then Result := "February"
			when 3 then Result := "March"
			when 4 then Result := "April"
			when 5 then Result := "May"
			when 6 then Result := "June"
			when 7 then Result := "July"
			when 8 then Result := "August"
			when 9 then Result := "September"
			when 10 then Result := "October"
			when 11 then Result := "November"
			when 12 then Result := "December"
			else
				Result := "Unknown"
			end
		ensure
			result_attached: Result /= Void
		end

	month_name_short: STRING
			-- Abbreviated month name (3 letters).
		do
			Result := month_name.substring (1, 3)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 3
		end

	weekday_name: STRING
			-- Full day of week name.
		do
			inspect day_of_week
			when 1 then Result := "Monday"
			when 2 then Result := "Tuesday"
			when 3 then Result := "Wednesday"
			when 4 then Result := "Thursday"
			when 5 then Result := "Friday"
			when 6 then Result := "Saturday"
			when 7 then Result := "Sunday"
			else
				Result := "Unknown"
			end
		ensure
			result_attached: Result /= Void
		end

	weekday_name_short: STRING
			-- Abbreviated day name (3 letters).
		do
			Result := weekday_name.substring (1, 3)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 3
		end

feature -- Conversion

	to_date: DATE
			-- Convert to Eiffel DATE.
		do
			Result := internal_date.twin
		ensure
			result_attached: Result /= Void
		end

	to_datetime (a_time: SIMPLE_TIME): SIMPLE_DATE_TIME
			-- Combine with a time to create datetime.
		require
			time_not_void: a_time /= Void
		do
			create Result.make (year, month, day, a_time.hour, a_time.minute, a_time.second)
		ensure
			result_attached: Result /= Void
		end

	at_midnight: SIMPLE_DATE_TIME
			-- This date at midnight (00:00:00).
		do
			create Result.make (year, month, day, 0, 0, 0)
		ensure
			result_attached: Result /= Void
		end

	at_noon: SIMPLE_DATE_TIME
			-- This date at noon (12:00:00).
		do
			create Result.make (year, month, day, 12, 0, 0)
		ensure
			result_attached: Result /= Void
		end

	at_end_of_day: SIMPLE_DATE_TIME
			-- This date at end of day (23:59:59).
		do
			create Result.make (year, month, day, 23, 59, 59)
		ensure
			result_attached: Result /= Void
		end

feature -- Query

	days_in_month: INTEGER
			-- Number of days in current month.
		do
			Result := days_in_month_for (year, month)
		ensure
			valid_range: Result >= 28 and Result <= 31
		end

feature {SIMPLE_DATE, SIMPLE_DATE_TIME, SIMPLE_AGE} -- Implementation

	internal_date: DATE
			-- Wrapped Eiffel DATE object.

feature {NONE} -- Implementation

	days_in_month_for (a_year, a_month: INTEGER): INTEGER
			-- Number of days in given month/year.
		require
			valid_month: a_month >= 1 and a_month <= 12
		do
			inspect a_month
			when 1, 3, 5, 7, 8, 10, 12 then
				Result := 31
			when 4, 6, 9, 11 then
				Result := 30
			when 2 then
				if internal_date.is_leap_year (a_year) then
					Result := 29
				else
					Result := 28
				end
			end
		ensure
			valid_range: Result >= 28 and Result <= 31
		end

invariant
	internal_date_attached: internal_date /= Void
	valid_month: month >= 1 and month <= 12
	valid_day: day >= 1 and day <= 31

end
