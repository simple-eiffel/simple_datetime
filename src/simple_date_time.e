note
	description: "[
		Simple Date Time - High-level wrapper combining date and time.

		Provides a fluent API for datetime manipulation with features like
		ISO 8601 parsing/formatting, Unix timestamps, timezone awareness,
		and human-friendly relative time output.

		Design influences:
		- Pylon library: Composition (contains date and time), timezone_bias
		- ISO8601 library: Validation and format patterns
		- Modern libraries: time_ago, time_until features

		Example:
			dt := create {SIMPLE_DATE_TIME}.make_now
			iso := dt.to_iso8601          -- "2025-12-07T14:30:00"
			ago := dt.time_ago            -- "5 minutes ago"
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DATE_TIME

inherit
	COMPARABLE
		redefine
			is_equal,
			out
		end

create
	make,
	make_now,
	make_now_utc,
	make_from_string,
	make_from_iso8601,
	make_from_timestamp,
	make_from_date_time

convert
	to_date_time: {DATE_TIME}

feature {NONE} -- Initialization

	make (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER)
			-- Create datetime from components.
		require
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 59
		do
			create internal_datetime.make (a_year, a_month, a_day, a_hour, a_minute, a_second)
		ensure
			year_set: year = a_year
			month_set: month = a_month
			day_set: day = a_day
			hour_set: hour = a_hour
			minute_set: minute = a_minute
			second_set: second = a_second
		end

	make_now
			-- Create datetime with current local date and time.
		do
			create internal_datetime.make_now
		end

	make_now_utc
			-- Create datetime with current UTC date and time.
		do
			create internal_datetime.make_now_utc
			is_utc := True
		end

	make_from_string (a_string: STRING)
			-- Create datetime from string, trying common formats.
			-- Supports: ISO 8601, common variants
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		local
			l_str, l_date_part, l_time_part: STRING
			l_date: SIMPLE_DATE
			l_time: SIMPLE_TIME
			l_sep_pos: INTEGER
		do
			l_str := a_string.twin
			l_str.left_adjust
			l_str.right_adjust

			-- Check for 'T' separator (ISO 8601)
			l_sep_pos := l_str.index_of ('T', 1)
			if l_sep_pos = 0 then
				-- Try space separator
				l_sep_pos := l_str.index_of (' ', 1)
			end

			if l_sep_pos > 0 then
				l_date_part := l_str.substring (1, l_sep_pos - 1)
				l_time_part := l_str.substring (l_sep_pos + 1, l_str.count)

				-- Remove timezone suffix if present
				if l_time_part.has ('Z') then
					l_time_part.remove (l_time_part.index_of ('Z', 1))
					is_utc := True
				end
				if l_time_part.has ('+') then
					l_time_part := l_time_part.substring (1, l_time_part.index_of ('+', 1) - 1)
				end
				if l_time_part.occurrences ('-') > 0 and l_time_part.count > 8 then
					-- Has timezone offset like -05:00
					l_time_part := l_time_part.substring (1, 8)
				end

				create l_date.make_from_string (l_date_part)
				create l_time.make_from_string (l_time_part)
			else
				-- Date only
				create l_date.make_from_string (l_str)
				create l_time.make (0, 0, 0)
			end

			create internal_datetime.make (l_date.year, l_date.month, l_date.day,
				l_time.hour, l_time.minute, l_time.second)
		end

	make_from_iso8601 (a_string: STRING)
			-- Create datetime from ISO 8601 format.
			-- Format: YYYY-MM-DDTHH:MM:SS or YYYY-MM-DDTHH:MM:SSZ
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		do
			make_from_string (a_string)
		end

	make_from_timestamp (a_unix_timestamp: INTEGER_64)
			-- Create datetime from Unix timestamp (seconds since 1970-01-01 UTC).
		local
			l_epoch: DATE_TIME
			l_duration: DATE_TIME_DURATION
		do
			create l_epoch.make (1970, 1, 1, 0, 0, 0)
			create l_duration.make (0, 0, 0, 0, 0, a_unix_timestamp.to_integer)
			l_epoch.add (l_duration)
			internal_datetime := l_epoch
			is_utc := True
		end

	make_from_date_time (a_datetime: DATE_TIME)
			-- Create from existing Eiffel DATE_TIME.
		require
			datetime_not_void: a_datetime /= Void
		do
			create internal_datetime.make (a_datetime.year, a_datetime.month,
				a_datetime.day, a_datetime.hour, a_datetime.minute, a_datetime.second)
		end

feature -- Access: Date Components

	year: INTEGER
			-- Year component.
		do
			Result := internal_datetime.year
		end

	month: INTEGER
			-- Month component (1-12).
		do
			Result := internal_datetime.month
		end

	day: INTEGER
			-- Day of month component (1-31).
		do
			Result := internal_datetime.day
		end

	day_of_week: INTEGER
			-- Day of week (1=Monday, 7=Sunday per ISO 8601).
		local
			l_date: SIMPLE_DATE
		do
			create l_date.make (year, month, day)
			Result := l_date.day_of_week
		end

	day_of_year: INTEGER
			-- Day of year (1-366).
		local
			l_jan1: DATE
		do
			create l_jan1.make (year, 1, 1)
			Result := internal_datetime.date.days - l_jan1.days + 1
		end

feature -- Access: Time Components

	hour: INTEGER
			-- Hour component (0-23).
		do
			Result := internal_datetime.hour
		end

	minute: INTEGER
			-- Minute component (0-59).
		do
			Result := internal_datetime.minute
		end

	second: INTEGER
			-- Second component (0-59).
		do
			Result := internal_datetime.second
		end

feature -- Access: Extracted

	date: SIMPLE_DATE
			-- Extract date part.
		do
			create Result.make (year, month, day)
		ensure
			result_attached: Result /= Void
		end

	time: SIMPLE_TIME
			-- Extract time part.
		do
			create Result.make (hour, minute, second)
		ensure
			result_attached: Result /= Void
		end

feature -- Status

	is_utc: BOOLEAN
			-- Is this datetime in UTC?

	is_today: BOOLEAN
			-- Is this datetime's date today?
		do
			Result := date.is_today
		end

	is_past: BOOLEAN
			-- Is this datetime in the past?
		local
			l_now: DATE_TIME
		do
			create l_now.make_now
			Result := internal_datetime < l_now
		end

	is_future: BOOLEAN
			-- Is this datetime in the future?
		local
			l_now: DATE_TIME
		do
			create l_now.make_now
			Result := internal_datetime > l_now
		end

feature -- Comparison

	is_before (other: SIMPLE_DATE_TIME): BOOLEAN
			-- Is this datetime before `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_datetime < other.internal_datetime
		end

	is_after (other: SIMPLE_DATE_TIME): BOOLEAN
			-- Is this datetime after `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_datetime > other.internal_datetime
		end

	is_less alias "<" (other: SIMPLE_DATE_TIME): BOOLEAN
			-- Is this datetime before `other'?
		do
			Result := internal_datetime < other.internal_datetime
		end

	is_equal (other: SIMPLE_DATE_TIME): BOOLEAN
			-- Is this datetime equal to `other'?
		do
			Result := internal_datetime.is_equal (other.internal_datetime)
		end

	seconds_between (other: SIMPLE_DATE_TIME): INTEGER_64
			-- Number of seconds between this datetime and `other'.
		require
			other_not_void: other /= Void
		do
			Result := other.to_timestamp - to_timestamp
		end

feature -- Arithmetic

	plus_days (a_days: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_days' added.
		do
			create Result.make (year, month, day, hour, minute, second)
			Result := Result.plus_seconds (a_days.to_integer_64 * 86400)
		ensure
			result_attached: Result /= Void
		end

	plus_hours (a_hours: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_hours' added.
		do
			Result := plus_seconds (a_hours.to_integer_64 * 3600)
		ensure
			result_attached: Result /= Void
		end

	plus_minutes (a_minutes: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_minutes' added.
		do
			Result := plus_seconds (a_minutes.to_integer_64 * 60)
		ensure
			result_attached: Result /= Void
		end

	plus_seconds (a_seconds: INTEGER_64): SIMPLE_DATE_TIME
			-- New datetime with `a_seconds' added.
		local
			l_timestamp: INTEGER_64
		do
			l_timestamp := to_timestamp + a_seconds
			create Result.make_from_timestamp (l_timestamp)
		ensure
			result_attached: Result /= Void
		end

	minus_days (a_days: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_days' subtracted.
		do
			Result := plus_days (-a_days)
		ensure
			result_attached: Result /= Void
		end

	minus_hours (a_hours: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_hours' subtracted.
		do
			Result := plus_hours (-a_hours)
		ensure
			result_attached: Result /= Void
		end

	minus_minutes (a_minutes: INTEGER): SIMPLE_DATE_TIME
			-- New datetime with `a_minutes' subtracted.
		do
			Result := plus_minutes (-a_minutes)
		ensure
			result_attached: Result /= Void
		end

feature -- Output: ISO 8601

	to_iso8601: STRING
			-- ISO 8601 format: "YYYY-MM-DDTHH:MM:SS"
		do
			create Result.make (19)
			Result.append (date.to_iso8601)
			Result.append_character ('T')
			Result.append (time.to_iso8601)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 19
		end

	to_iso8601_utc: STRING
			-- ISO 8601 UTC format: "YYYY-MM-DDTHH:MM:SSZ"
		do
			Result := to_iso8601
			Result.append_character ('Z')
		ensure
			result_attached: Result /= Void
		end

	to_iso8601_date: STRING
			-- ISO 8601 date only: "YYYY-MM-DD"
		do
			Result := date.to_iso8601
		ensure
			result_attached: Result /= Void
		end

feature -- Output: Human-Friendly (Innovative!)

	time_ago: STRING
			-- Human-readable relative time in past.
			-- Examples: "just now", "5 minutes ago", "2 hours ago", "yesterday", "3 days ago"
		local
			l_now: DATE_TIME
			l_diff_seconds: INTEGER_64
			l_minutes, l_hours, l_days: INTEGER
		do
			create l_now.make_now
			l_diff_seconds := datetime_to_seconds (l_now) - datetime_to_seconds (internal_datetime)

			if l_diff_seconds < 0 then
				Result := time_until
			elseif l_diff_seconds < 60 then
				Result := "just now"
			elseif l_diff_seconds < 3600 then
				l_minutes := (l_diff_seconds // 60).to_integer
				if l_minutes = 1 then
					Result := "1 minute ago"
				else
					Result := l_minutes.out + " minutes ago"
				end
			elseif l_diff_seconds < 86400 then
				l_hours := (l_diff_seconds // 3600).to_integer
				if l_hours = 1 then
					Result := "1 hour ago"
				else
					Result := l_hours.out + " hours ago"
				end
			elseif l_diff_seconds < 172800 then
				Result := "yesterday"
			elseif l_diff_seconds < 604800 then
				l_days := (l_diff_seconds // 86400).to_integer
				Result := l_days.out + " days ago"
			elseif l_diff_seconds < 2592000 then
				l_days := (l_diff_seconds // 604800).to_integer
				if l_days = 1 then
					Result := "1 week ago"
				else
					Result := l_days.out + " weeks ago"
				end
			elseif l_diff_seconds < 31536000 then
				l_days := (l_diff_seconds // 2592000).to_integer
				if l_days = 1 then
					Result := "1 month ago"
				else
					Result := l_days.out + " months ago"
				end
			else
				l_days := (l_diff_seconds // 31536000).to_integer
				if l_days = 1 then
					Result := "1 year ago"
				else
					Result := l_days.out + " years ago"
				end
			end
		ensure
			result_attached: Result /= Void
		end

	time_until: STRING
			-- Human-readable relative time in future.
			-- Examples: "in 5 minutes", "in 2 hours", "tomorrow", "in 3 days"
		local
			l_now: DATE_TIME
			l_diff_seconds: INTEGER_64
			l_minutes, l_hours, l_days: INTEGER
		do
			create l_now.make_now
			l_diff_seconds := datetime_to_seconds (internal_datetime) - datetime_to_seconds (l_now)

			if l_diff_seconds < 0 then
				Result := time_ago
			elseif l_diff_seconds < 60 then
				Result := "now"
			elseif l_diff_seconds < 3600 then
				l_minutes := (l_diff_seconds // 60).to_integer
				if l_minutes = 1 then
					Result := "in 1 minute"
				else
					Result := "in " + l_minutes.out + " minutes"
				end
			elseif l_diff_seconds < 86400 then
				l_hours := (l_diff_seconds // 3600).to_integer
				if l_hours = 1 then
					Result := "in 1 hour"
				else
					Result := "in " + l_hours.out + " hours"
				end
			elseif l_diff_seconds < 172800 then
				Result := "tomorrow"
			elseif l_diff_seconds < 604800 then
				l_days := (l_diff_seconds // 86400).to_integer
				Result := "in " + l_days.out + " days"
			elseif l_diff_seconds < 2592000 then
				l_days := (l_diff_seconds // 604800).to_integer
				if l_days = 1 then
					Result := "in 1 week"
				else
					Result := "in " + l_days.out + " weeks"
				end
			elseif l_diff_seconds < 31536000 then
				l_days := (l_diff_seconds // 2592000).to_integer
				if l_days = 1 then
					Result := "in 1 month"
				else
					Result := "in " + l_days.out + " months"
				end
			else
				l_days := (l_diff_seconds // 31536000).to_integer
				if l_days = 1 then
					Result := "in 1 year"
				else
					Result := "in " + l_days.out + " years"
				end
			end
		ensure
			result_attached: Result /= Void
		end

	to_human: STRING
			-- Human-readable format: "December 7, 2025 at 2:30 PM"
		do
			create Result.make (30)
			Result.append (date.to_human)
			Result.append_string (" at ")
			Result.append (time.to_12hour)
		ensure
			result_attached: Result /= Void
		end

	to_human_short: STRING
			-- Short human format: "Dec 7, 2025 2:30 PM"
		do
			create Result.make (20)
			Result.append (date.to_human_short)
			Result.append_character (' ')
			Result.append (time.to_12hour)
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation (ISO 8601).
		do
			Result := to_iso8601
		end

feature -- Conversion

	to_date_time: DATE_TIME
			-- Convert to Eiffel DATE_TIME.
		do
			Result := internal_datetime.twin
		ensure
			result_attached: Result /= Void
		end

	to_timestamp: INTEGER_64
			-- Convert to Unix timestamp (seconds since 1970-01-01 UTC).
		local
			l_epoch: DATE_TIME
		do
			create l_epoch.make (1970, 1, 1, 0, 0, 0)
			Result := datetime_to_seconds (internal_datetime) - datetime_to_seconds (l_epoch)
		end

feature {SIMPLE_DATE_TIME} -- Implementation

	internal_datetime: DATE_TIME
			-- Wrapped Eiffel DATE_TIME object.

feature {NONE} -- Implementation

	datetime_to_seconds (a_dt: DATE_TIME): INTEGER_64
			-- Convert datetime to seconds for comparison.
			-- This is a simplified calculation for relative comparisons.
		local
			l_days: INTEGER_64
		do
			-- Calculate total days from a base date
			l_days := a_dt.date.days.to_integer_64
			-- Convert to seconds and add time
			Result := l_days * 86400 + a_dt.hour * 3600 + a_dt.minute * 60 + a_dt.second
		end

invariant
	internal_datetime_attached: internal_datetime /= Void

end
