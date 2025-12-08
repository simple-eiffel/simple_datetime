note
	description: "[
		Simple Time - High-level wrapper over Eiffel's TIME class.

		Provides a fluent API for time manipulation with features like
		12-hour format support, period detection, and multiple output formats.

		Design influences:
		- Pylon library: hour_12, is_am, is_pm concepts
		- ISO8601 library: Validation and format patterns

		Example:
			t := create {SIMPLE_TIME}.make (14, 30, 0)
			is_afternoon := t.is_pm
			formatted := t.to_12hour  -- "2:30 PM"
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_TIME

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
	make_from_time,
	make_from_seconds

convert
	to_time: {TIME}

feature {NONE} -- Initialization

	make (a_hour, a_minute, a_second: INTEGER)
			-- Create time from components.
		require
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 59
		do
			create internal_time.make (a_hour, a_minute, a_second)
		ensure
			hour_set: hour = a_hour
			minute_set: minute = a_minute
			second_set: second = a_second
		end

	make_now
			-- Create time with current time.
		do
			create internal_time.make_now
		end

	make_from_string (a_string: STRING)
			-- Create time from string.
			-- Supports: HH:MM:SS, HH:MM, HHMMSS, HH:MM AM/PM
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		local
			l_hour, l_minute, l_second: INTEGER
			l_parts: LIST [STRING]
			l_str: STRING
			l_is_pm: BOOLEAN
		do
			l_str := a_string.twin
			l_str.left_adjust
			l_str.right_adjust
			l_str.to_upper

			-- Check for AM/PM suffix
			if l_str.has_substring ("PM") then
				l_is_pm := True
				l_str.replace_substring_all ("PM", "")
			elseif l_str.has_substring ("AM") then
				l_str.replace_substring_all ("AM", "")
			end
			l_str.left_adjust
			l_str.right_adjust

			if l_str.count = 6 and then l_str.is_integer then
				-- HHMMSS format
				l_hour := l_str.substring (1, 2).to_integer
				l_minute := l_str.substring (3, 4).to_integer
				l_second := l_str.substring (5, 6).to_integer
			elseif l_str.has (':') then
				-- HH:MM:SS or HH:MM format
				l_parts := l_str.split (':')
				if l_parts.count >= 2 then
					l_hour := l_parts [1].to_integer
					l_minute := l_parts [2].to_integer
					if l_parts.count >= 3 then
						l_second := l_parts [3].to_integer
					end
				end
			end

			-- Handle 12-hour to 24-hour conversion
			if l_is_pm and l_hour < 12 then
				l_hour := l_hour + 12
			elseif not l_is_pm and l_hour = 12 then
				l_hour := 0
			end

			-- Clamp to valid ranges
			l_hour := l_hour.max (0).min (23)
			l_minute := l_minute.max (0).min (59)
			l_second := l_second.max (0).min (59)

			create internal_time.make (l_hour, l_minute, l_second)
		end

	make_from_time (a_time: TIME)
			-- Create from existing Eiffel TIME.
		require
			time_not_void: a_time /= Void
		do
			create internal_time.make (a_time.hour, a_time.minute, a_time.second)
		end

	make_from_seconds (a_seconds: INTEGER)
			-- Create from seconds since midnight.
		require
			valid_seconds: a_seconds >= 0 and a_seconds < 86400
		local
			l_remaining: INTEGER
		do
			l_remaining := a_seconds
			create internal_time.make (l_remaining // 3600, (l_remaining \\ 3600) // 60, l_remaining \\ 60)
		end

feature -- Access

	hour: INTEGER
			-- Hour component (0-23).
		do
			Result := internal_time.hour
		ensure
			valid_range: Result >= 0 and Result <= 23
		end

	minute: INTEGER
			-- Minute component (0-59).
		do
			Result := internal_time.minute
		ensure
			valid_range: Result >= 0 and Result <= 59
		end

	second: INTEGER
			-- Second component (0-59).
		do
			Result := internal_time.second
		ensure
			valid_range: Result >= 0 and Result <= 59
		end

	hour_12: INTEGER
			-- Hour in 12-hour format (1-12).
			-- Influenced by Pylon library design.
		do
			Result := hour \\ 12
			if Result = 0 then
				Result := 12
			end
		ensure
			valid_range: Result >= 1 and Result <= 12
		end

	seconds_since_midnight: INTEGER
			-- Total seconds since midnight.
		do
			Result := hour * 3600 + minute * 60 + second
		ensure
			valid_range: Result >= 0 and Result < 86400
		end

feature -- Status (Influenced by Pylon)

	is_am: BOOLEAN
			-- Is this time in the AM (before noon)?
		do
			Result := hour < 12
		end

	is_pm: BOOLEAN
			-- Is this time in the PM (noon or after)?
		do
			Result := hour >= 12
		end

	is_midnight: BOOLEAN
			-- Is this exactly midnight (00:00:00)?
		do
			Result := hour = 0 and minute = 0 and second = 0
		end

	is_noon: BOOLEAN
			-- Is this exactly noon (12:00:00)?
		do
			Result := hour = 12 and minute = 0 and second = 0
		end

	is_morning: BOOLEAN
			-- Is this morning (00:00 - 11:59)?
		do
			Result := hour < 12
		end

	is_afternoon: BOOLEAN
			-- Is this afternoon (12:00 - 17:59)?
		do
			Result := hour >= 12 and hour < 18
		end

	is_evening: BOOLEAN
			-- Is this evening (18:00 - 23:59)?
		do
			Result := hour >= 18
		end

feature -- Comparison

	is_before (other: SIMPLE_TIME): BOOLEAN
			-- Is this time before `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_time < other.internal_time
		end

	is_after (other: SIMPLE_TIME): BOOLEAN
			-- Is this time after `other'?
		require
			other_not_void: other /= Void
		do
			Result := internal_time > other.internal_time
		end

	is_less alias "<" (other: SIMPLE_TIME): BOOLEAN
			-- Is this time before `other'?
		do
			Result := internal_time < other.internal_time
		end

	is_equal (other: SIMPLE_TIME): BOOLEAN
			-- Is this time equal to `other'?
		do
			Result := internal_time.is_equal (other.internal_time)
		end

	seconds_between (other: SIMPLE_TIME): INTEGER
			-- Number of seconds between this time and `other'.
			-- Positive if `other' is after this time.
		require
			other_not_void: other /= Void
		do
			Result := other.seconds_since_midnight - seconds_since_midnight
		end

feature -- Arithmetic

	plus_hours (a_hours: INTEGER): SIMPLE_TIME
			-- New time with `a_hours' added (wraps at 24).
		local
			l_seconds: INTEGER
		do
			l_seconds := (seconds_since_midnight + a_hours * 3600) \\ 86400
			if l_seconds < 0 then
				l_seconds := l_seconds + 86400
			end
			create Result.make_from_seconds (l_seconds)
		ensure
			result_attached: Result /= Void
		end

	plus_minutes (a_minutes: INTEGER): SIMPLE_TIME
			-- New time with `a_minutes' added (wraps at 24 hours).
		local
			l_seconds: INTEGER
		do
			l_seconds := (seconds_since_midnight + a_minutes * 60) \\ 86400
			if l_seconds < 0 then
				l_seconds := l_seconds + 86400
			end
			create Result.make_from_seconds (l_seconds)
		ensure
			result_attached: Result /= Void
		end

	plus_seconds (a_seconds: INTEGER): SIMPLE_TIME
			-- New time with `a_seconds' added (wraps at 24 hours).
		local
			l_secs: INTEGER
		do
			l_secs := (seconds_since_midnight + a_seconds) \\ 86400
			if l_secs < 0 then
				l_secs := l_secs + 86400
			end
			create Result.make_from_seconds (l_secs)
		ensure
			result_attached: Result /= Void
		end

	minus_hours (a_hours: INTEGER): SIMPLE_TIME
			-- New time with `a_hours' subtracted.
		do
			Result := plus_hours (-a_hours)
		ensure
			result_attached: Result /= Void
		end

	minus_minutes (a_minutes: INTEGER): SIMPLE_TIME
			-- New time with `a_minutes' subtracted.
		do
			Result := plus_minutes (-a_minutes)
		ensure
			result_attached: Result /= Void
		end

	minus_seconds (a_seconds: INTEGER): SIMPLE_TIME
			-- New time with `a_seconds' subtracted.
		do
			Result := plus_seconds (-a_seconds)
		ensure
			result_attached: Result /= Void
		end

feature -- Output (Multiple formats)

	to_iso8601: STRING
			-- ISO 8601 format: "HH:MM:SS"
		do
			create Result.make (8)
			if hour < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (hour)
			Result.append_character (':')
			if minute < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minute)
			Result.append_character (':')
			if second < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (second)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 8
		end

	to_iso_compact: STRING
			-- Compact format: "HHMMSS"
		do
			create Result.make (6)
			if hour < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (hour)
			if minute < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minute)
			if second < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (second)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 6
		end

	to_short: STRING
			-- Short format: "HH:MM"
		do
			create Result.make (5)
			if hour < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (hour)
			Result.append_character (':')
			if minute < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minute)
		ensure
			result_attached: Result /= Void
			correct_length: Result.count = 5
		end

	to_12hour: STRING
			-- 12-hour format: "2:30 PM"
		do
			create Result.make (8)
			Result.append_integer (hour_12)
			Result.append_character (':')
			if minute < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minute)
			if is_am then
				Result.append_string (" AM")
			else
				Result.append_string (" PM")
			end
		ensure
			result_attached: Result /= Void
		end

	to_12hour_with_seconds: STRING
			-- 12-hour format with seconds: "2:30:15 PM"
		do
			create Result.make (12)
			Result.append_integer (hour_12)
			Result.append_character (':')
			if minute < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minute)
			Result.append_character (':')
			if second < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (second)
			if is_am then
				Result.append_string (" AM")
			else
				Result.append_string (" PM")
			end
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation (ISO 8601).
		do
			Result := to_iso8601
		end

feature -- Conversion

	to_time: TIME
			-- Convert to Eiffel TIME.
		do
			Result := internal_time.twin
		ensure
			result_attached: Result /= Void
		end

feature {SIMPLE_TIME, SIMPLE_DATE_TIME} -- Implementation

	internal_time: TIME
			-- Wrapped Eiffel TIME object.

invariant
	internal_time_attached: internal_time /= Void
	valid_hour: hour >= 0 and hour <= 23
	valid_minute: minute >= 0 and minute <= 59
	valid_second: second >= 0 and second <= 59

end
