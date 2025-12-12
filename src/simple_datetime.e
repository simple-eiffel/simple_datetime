note
	description: "[
		Simple DateTime - High-level facade for date/time operations.

		Provides factory methods, parsing, and convenience features.
		Wraps EiffelStudio's TIME library with a cleaner, fluent API.

		Features:
		- Factory methods: now, today, date, time, datetime
		- Smart parsing: automatically detects common formats
		- Relative dates: next_monday, last_friday, etc.
		- Human-friendly output: time_ago, time_until
		- Business day support
		- Age calculation

		Example:
			create dt.make
			today := dt.today
			next_week := dt.today.plus_days (7)
			age := dt.age_from (birthdate)
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DATETIME

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize datetime processor.
		do
			-- Ready to use
		end

feature -- Factory: Current Time

	now,
	current_time,
	current_datetime,
	timestamp: SIMPLE_DATE_TIME
			-- Current date and time in local timezone.
		do
			create Result.make_now
		ensure
			result_attached: Result /= Void
		end

	utc_now,
	utc_timestamp,
	current_utc: SIMPLE_DATE_TIME
			-- Current date and time in UTC.
		do
			create Result.make_now_utc
		ensure
			result_attached: Result /= Void
		end

	today,
	current_date,
	todays_date: SIMPLE_DATE
			-- Today's date.
		do
			create Result.make_now
		ensure
			result_attached: Result /= Void
		end

	tomorrow: SIMPLE_DATE
			-- Tomorrow's date.
		do
			Result := today.plus_days (1)
		ensure
			result_attached: Result /= Void
		end

	yesterday: SIMPLE_DATE
			-- Yesterday's date.
		do
			Result := today.minus_days (1)
		ensure
			result_attached: Result /= Void
		end

feature -- Factory: Creation

	date,
	new_date,
	make_date,
	create_date (a_year, a_month, a_day: INTEGER): SIMPLE_DATE
			-- Create date from components.
		require
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
		do
			create Result.make (a_year, a_month, a_day)
		ensure
			result_attached: Result /= Void
			year_set: Result.year = a_year
			month_set: Result.month = a_month
			day_set: Result.day = a_day
		end

	time,
	new_time,
	make_time,
	create_time (a_hour, a_minute, a_second: INTEGER): SIMPLE_TIME
			-- Create time from components.
		require
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 59
		do
			create Result.make (a_hour, a_minute, a_second)
		ensure
			result_attached: Result /= Void
			hour_set: Result.hour = a_hour
			minute_set: Result.minute = a_minute
			second_set: Result.second = a_second
		end

	datetime,
	new_datetime,
	make_datetime,
	create_datetime (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER): SIMPLE_DATE_TIME
			-- Create datetime from components.
		require
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 59
		do
			create Result.make (a_year, a_month, a_day, a_hour, a_minute, a_second)
		ensure
			result_attached: Result /= Void
		end

feature -- Factory: From Timestamp

	from_timestamp,
	from_unix,
	from_epoch,
	unix_to_datetime (a_unix_timestamp: INTEGER_64): SIMPLE_DATE_TIME
			-- Create datetime from Unix timestamp (seconds since 1970-01-01).
		do
			create Result.make_from_timestamp (a_unix_timestamp)
		ensure
			result_attached: Result /= Void
		end

feature -- Parsing

	parse_date,
	decode_date,
	date_from_string,
	string_to_date (a_string: STRING): SIMPLE_DATE
			-- Parse date from string, trying common formats.
			-- Supports: YYYY-MM-DD, MM/DD/YYYY, DD.MM.YYYY
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		do
			create Result.make_from_string (a_string)
		ensure
			result_attached: Result /= Void
		end

	parse_datetime,
	decode_datetime,
	datetime_from_string,
	string_to_datetime (a_string: STRING): SIMPLE_DATE_TIME
			-- Parse datetime from string, trying common formats.
			-- Supports: ISO 8601 and common variants
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		do
			create Result.make_from_string (a_string)
		ensure
			result_attached: Result /= Void
		end

	parse_iso8601,
	decode_iso8601,
	from_iso8601,
	iso_to_datetime (a_string: STRING): SIMPLE_DATE_TIME
			-- Parse ISO 8601 formatted datetime.
			-- Format: YYYY-MM-DDTHH:MM:SS or YYYY-MM-DDTHH:MM:SSZ
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		do
			create Result.make_from_iso8601 (a_string)
		ensure
			result_attached: Result /= Void
		end

feature -- Relative Dates (Innovative!)

	next_monday: SIMPLE_DATE
			-- Next Monday from today.
		do
			Result := today.next_weekday (1)
		ensure
			result_attached: Result /= Void
			is_monday: Result.day_of_week = 1
		end

	next_tuesday: SIMPLE_DATE
			-- Next Tuesday from today.
		do
			Result := today.next_weekday (2)
		ensure
			result_attached: Result /= Void
		end

	next_wednesday: SIMPLE_DATE
			-- Next Wednesday from today.
		do
			Result := today.next_weekday (3)
		ensure
			result_attached: Result /= Void
		end

	next_thursday: SIMPLE_DATE
			-- Next Thursday from today.
		do
			Result := today.next_weekday (4)
		ensure
			result_attached: Result /= Void
		end

	next_friday: SIMPLE_DATE
			-- Next Friday from today.
		do
			Result := today.next_weekday (5)
		ensure
			result_attached: Result /= Void
		end

	last_monday: SIMPLE_DATE
			-- Last Monday (most recent past Monday).
		do
			Result := today.previous_weekday (1)
		ensure
			result_attached: Result /= Void
		end

	last_friday: SIMPLE_DATE
			-- Last Friday (most recent past Friday).
		do
			Result := today.previous_weekday (5)
		ensure
			result_attached: Result /= Void
		end

	first_of_month: SIMPLE_DATE
			-- First day of current month.
		do
			Result := today.start_of_month
		ensure
			result_attached: Result /= Void
			is_first: Result.day = 1
		end

	last_of_month: SIMPLE_DATE
			-- Last day of current month.
		do
			Result := today.end_of_month
		ensure
			result_attached: Result /= Void
		end

	first_of_next_month: SIMPLE_DATE
			-- First day of next month.
		do
			Result := today.plus_months (1).start_of_month
		ensure
			result_attached: Result /= Void
		end

	first_of_year: SIMPLE_DATE
			-- First day of current year.
		do
			Result := today.start_of_year
		ensure
			result_attached: Result /= Void
			is_january_first: Result.month = 1 and Result.day = 1
		end

	last_of_year: SIMPLE_DATE
			-- Last day of current year.
		do
			Result := today.end_of_year
		ensure
			result_attached: Result /= Void
			is_december_31: Result.month = 12 and Result.day = 31
		end

feature -- Age Calculation (Innovative!)

	age_from (a_birthdate: SIMPLE_DATE): SIMPLE_AGE
			-- Calculate age from birthdate to today.
		require
			birthdate_not_void: a_birthdate /= Void
			birthdate_in_past: a_birthdate.is_before (today) or a_birthdate.is_equal (today)
		do
			create Result.make_from_dates (a_birthdate, today)
		ensure
			result_attached: Result /= Void
		end

	age_between (a_start, a_end: SIMPLE_DATE): SIMPLE_AGE
			-- Calculate age/duration between two dates.
		require
			start_not_void: a_start /= Void
			end_not_void: a_end /= Void
			start_before_end: a_start.is_before (a_end) or a_start.is_equal (a_end)
		do
			create Result.make_from_dates (a_start, a_end)
		ensure
			result_attached: Result /= Void
		end

feature -- Business Days (Innovative!)

	add_business_days (a_date: SIMPLE_DATE; a_days: INTEGER): SIMPLE_DATE
			-- Add `a_days' business days to `a_date' (skipping weekends).
		require
			date_not_void: a_date /= Void
			days_positive: a_days >= 0
		do
			Result := a_date.plus_business_days (a_days)
		ensure
			result_attached: Result /= Void
		end

	business_days_between (a_start, a_end: SIMPLE_DATE): INTEGER
			-- Count business days between two dates.
		require
			start_not_void: a_start /= Void
			end_not_void: a_end /= Void
		do
			Result := a_start.business_days_until (a_end)
		end

	is_business_day (a_date: SIMPLE_DATE): BOOLEAN
			-- Is `a_date' a business day (weekday)?
		require
			date_not_void: a_date /= Void
		do
			Result := a_date.is_weekday
		end

	next_business_day (a_date: SIMPLE_DATE): SIMPLE_DATE
			-- Next business day after `a_date'.
		require
			date_not_void: a_date /= Void
		do
			Result := a_date.plus_business_days (1)
		ensure
			result_attached: Result /= Void
			is_weekday: Result.is_weekday
		end

feature -- Duration

	duration: SIMPLE_DURATION
			-- Create a new duration builder.
		do
			create Result.make_zero
		ensure
			result_attached: Result /= Void
		end

	days (a_count: INTEGER): SIMPLE_DURATION
			-- Duration of `a_count' days.
		do
			create Result.make_days (a_count)
		ensure
			result_attached: Result /= Void
		end

	hours (a_count: INTEGER): SIMPLE_DURATION
			-- Duration of `a_count' hours.
		do
			create Result.make_hours (a_count)
		ensure
			result_attached: Result /= Void
		end

	minutes (a_count: INTEGER): SIMPLE_DURATION
			-- Duration of `a_count' minutes.
		do
			create Result.make_minutes (a_count)
		ensure
			result_attached: Result /= Void
		end

feature -- Human-Friendly Output (Innovative!)

	time_ago (a_datetime: SIMPLE_DATE_TIME): STRING
			-- Human-readable relative time in past.
			-- Examples: "just now", "5 minutes ago", "2 hours ago", "yesterday", "3 days ago"
		require
			datetime_not_void: a_datetime /= Void
		do
			Result := a_datetime.time_ago
		ensure
			result_attached: Result /= Void
		end

	time_until (a_datetime: SIMPLE_DATE_TIME): STRING
			-- Human-readable relative time in future.
			-- Examples: "in 5 minutes", "in 2 hours", "tomorrow", "in 3 days"
		require
			datetime_not_void: a_datetime /= Void
		do
			Result := a_datetime.time_until
		ensure
			result_attached: Result /= Void
		end

feature -- Date Range

	date_range (a_start, a_end: SIMPLE_DATE): SIMPLE_DATE_RANGE
			-- Create a date range between two dates.
		require
			start_not_void: a_start /= Void
			end_not_void: a_end /= Void
		do
			create Result.make (a_start, a_end)
		ensure
			result_attached: Result /= Void
		end

end
