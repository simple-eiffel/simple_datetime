note
	description: "[
		Simple Duration - Represents a length of time.

		Provides a fluent API for duration creation and manipulation.
		Can represent durations in various units: days, hours, minutes, seconds.

		Design influences:
		- Eiffel Loop: EL_TIME_DURATION concepts
		- Java Duration/Period: Separate time-based vs date-based durations
		- ISO 8601: Duration format (PnDTnHnMnS)

		Example:
			d := create {SIMPLE_DURATION}.make_hours (2)
			d2 := d.plus_minutes (30)  -- 2 hours 30 minutes
			total := d2.total_seconds  -- 9000
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DURATION

inherit
	COMPARABLE
		redefine
			is_equal,
			out
		end

create
	make_zero,
	make,
	make_days,
	make_hours,
	make_minutes,
	make_seconds,
	make_from_string

feature {NONE} -- Initialization

	make_zero
			-- Create zero duration.
		do
			total_seconds_internal := 0
		ensure
			is_zero: is_zero
		end

	make (a_days, a_hours, a_minutes, a_seconds: INTEGER)
			-- Create duration from components.
		do
			total_seconds_internal := a_days.to_integer_64 * 86400 +
				a_hours.to_integer_64 * 3600 +
				a_minutes.to_integer_64 * 60 +
				a_seconds.to_integer_64
		end

	make_days (a_days: INTEGER)
			-- Create duration of `a_days' days.
		do
			total_seconds_internal := a_days.to_integer_64 * 86400
		ensure
			correct_days: days = a_days
		end

	make_hours (a_hours: INTEGER)
			-- Create duration of `a_hours' hours.
		do
			total_seconds_internal := a_hours.to_integer_64 * 3600
		ensure
			correct_hours: hours = a_hours
		end

	make_minutes (a_minutes: INTEGER)
			-- Create duration of `a_minutes' minutes.
		do
			total_seconds_internal := a_minutes.to_integer_64 * 60
		ensure
			correct_minutes: minutes = a_minutes
		end

	make_seconds (a_seconds: INTEGER_64)
			-- Create duration of `a_seconds' seconds.
		do
			total_seconds_internal := a_seconds
		ensure
			correct_seconds: total_seconds = a_seconds
		end

	make_from_string (a_string: STRING)
			-- Create duration from ISO 8601 format.
			-- Format: PnDTnHnMnS (e.g., "P2DT3H30M" = 2 days 3 hours 30 minutes)
		require
			string_not_empty: a_string /= Void and then not a_string.is_empty
		local
			l_str: STRING
			l_days, l_hours, l_minutes, l_seconds: INTEGER
			l_in_time: BOOLEAN
			l_current_num: STRING
			i: INTEGER
			c: CHARACTER
		do
			l_str := a_string.twin
			l_str.to_upper
			create l_current_num.make_empty

			from
				i := 1
			until
				i > l_str.count
			loop
				c := l_str.item (i)
				if c = 'P' then
					-- Start of duration, ignore
				elseif c = 'T' then
					l_in_time := True
				elseif c.is_digit then
					l_current_num.append_character (c)
				elseif c = 'D' then
					if not l_current_num.is_empty then
						l_days := l_current_num.to_integer
						l_current_num.wipe_out
					end
				elseif c = 'H' then
					if not l_current_num.is_empty then
						l_hours := l_current_num.to_integer
						l_current_num.wipe_out
					end
				elseif c = 'M' then
					if not l_current_num.is_empty then
						l_minutes := l_current_num.to_integer
						l_current_num.wipe_out
					end
				elseif c = 'S' then
					if not l_current_num.is_empty then
						l_seconds := l_current_num.to_integer
						l_current_num.wipe_out
					end
				end
				i := i + 1
			end

			make (l_days, l_hours, l_minutes, l_seconds)
		end

feature -- Access: Total

	total_seconds: INTEGER_64
			-- Total duration in seconds.
		do
			Result := total_seconds_internal.abs
		end

	total_minutes: INTEGER_64
			-- Total duration in minutes (truncated).
		do
			Result := total_seconds // 60
		end

	total_hours: INTEGER_64
			-- Total duration in hours (truncated).
		do
			Result := total_seconds // 3600
		end

	total_days: INTEGER_64
			-- Total duration in days (truncated).
		do
			Result := total_seconds // 86400
		end

feature -- Access: Components

	days: INTEGER
			-- Days component.
		do
			Result := (total_seconds_internal.abs // 86400).to_integer
		end

	hours: INTEGER
			-- Hours component (0-23).
		do
			Result := ((total_seconds_internal.abs \\ 86400) // 3600).to_integer
		end

	minutes: INTEGER
			-- Minutes component (0-59).
		do
			Result := ((total_seconds_internal.abs \\ 3600) // 60).to_integer
		end

	seconds: INTEGER
			-- Seconds component (0-59).
		do
			Result := (total_seconds_internal.abs \\ 60).to_integer
		end

feature -- Status

	is_zero: BOOLEAN
			-- Is this a zero duration?
		do
			Result := total_seconds_internal = 0
		end

	is_negative: BOOLEAN
			-- Is this a negative duration?
		do
			Result := total_seconds_internal < 0
		end

	is_positive: BOOLEAN
			-- Is this a positive duration?
		do
			Result := total_seconds_internal > 0
		end

feature -- Comparison

	is_less alias "<" (other: SIMPLE_DURATION): BOOLEAN
			-- Is this duration less than `other'?
		do
			Result := total_seconds_internal < other.total_seconds_internal
		end

	is_equal (other: SIMPLE_DURATION): BOOLEAN
			-- Is this duration equal to `other'?
		do
			Result := total_seconds_internal = other.total_seconds_internal
		end

feature -- Arithmetic

	plus alias "+" (other: SIMPLE_DURATION): SIMPLE_DURATION
			-- Sum of this duration and `other'.
		require
			other_not_void: other /= Void
		do
			create Result.make_seconds (total_seconds_internal + other.total_seconds_internal)
		ensure
			result_attached: Result /= Void
		end

	minus alias "-" (other: SIMPLE_DURATION): SIMPLE_DURATION
			-- Difference between this duration and `other'.
		require
			other_not_void: other /= Void
		do
			create Result.make_seconds (total_seconds_internal - other.total_seconds_internal)
		ensure
			result_attached: Result /= Void
		end

	negated: SIMPLE_DURATION
			-- Negated duration.
		do
			create Result.make_seconds (-total_seconds_internal)
		ensure
			result_attached: Result /= Void
		end

	multiplied alias "*" (a_factor: INTEGER): SIMPLE_DURATION
			-- Duration multiplied by `a_factor'.
		do
			create Result.make_seconds (total_seconds_internal * a_factor)
		ensure
			result_attached: Result /= Void
		end

	absolute: SIMPLE_DURATION
			-- Absolute value of duration.
		do
			create Result.make_seconds (total_seconds_internal.abs)
		ensure
			result_attached: Result /= Void
			is_positive_or_zero: Result.total_seconds >= 0
		end

feature -- Fluent Builder

	plus_days (a_days: INTEGER): SIMPLE_DURATION
			-- New duration with `a_days' added.
		do
			create Result.make_seconds (total_seconds_internal + a_days.to_integer_64 * 86400)
		ensure
			result_attached: Result /= Void
		end

	plus_hours (a_hours: INTEGER): SIMPLE_DURATION
			-- New duration with `a_hours' added.
		do
			create Result.make_seconds (total_seconds_internal + a_hours.to_integer_64 * 3600)
		ensure
			result_attached: Result /= Void
		end

	plus_minutes (a_minutes: INTEGER): SIMPLE_DURATION
			-- New duration with `a_minutes' added.
		do
			create Result.make_seconds (total_seconds_internal + a_minutes.to_integer_64 * 60)
		ensure
			result_attached: Result /= Void
		end

	plus_seconds (a_seconds: INTEGER): SIMPLE_DURATION
			-- New duration with `a_seconds' added.
		do
			create Result.make_seconds (total_seconds_internal + a_seconds.to_integer_64)
		ensure
			result_attached: Result /= Void
		end

feature -- Output

	to_iso8601: STRING
			-- ISO 8601 duration format: "PnDTnHnMnS"
		do
			create Result.make (20)
			Result.append_character ('P')
			if days > 0 then
				Result.append_integer (days)
				Result.append_character ('D')
			end
			if hours > 0 or minutes > 0 or seconds > 0 then
				Result.append_character ('T')
				if hours > 0 then
					Result.append_integer (hours)
					Result.append_character ('H')
				end
				if minutes > 0 then
					Result.append_integer (minutes)
					Result.append_character ('M')
				end
				if seconds > 0 then
					Result.append_integer (seconds)
					Result.append_character ('S')
				end
			end
			if Result.count = 1 then
				-- Zero duration
				Result.append_string ("T0S")
			end
		ensure
			result_attached: Result /= Void
		end

	to_human: STRING
			-- Human-readable format: "2 days, 3 hours, 30 minutes"
		local
			l_parts: ARRAYED_LIST [STRING]
		do
			create l_parts.make (4)

			if days > 0 then
				if days = 1 then
					l_parts.extend ("1 day")
				else
					l_parts.extend (days.out + " days")
				end
			end
			if hours > 0 then
				if hours = 1 then
					l_parts.extend ("1 hour")
				else
					l_parts.extend (hours.out + " hours")
				end
			end
			if minutes > 0 then
				if minutes = 1 then
					l_parts.extend ("1 minute")
				else
					l_parts.extend (minutes.out + " minutes")
				end
			end
			if seconds > 0 or l_parts.is_empty then
				if seconds = 1 then
					l_parts.extend ("1 second")
				else
					l_parts.extend (seconds.out + " seconds")
				end
			end

			create Result.make (50)
			across l_parts as ic_part loop
				if Result.count > 0 then
					Result.append_string (", ")
				end
				Result.append (ic_part)
			end
		ensure
			result_attached: Result /= Void
		end

	to_short: STRING
			-- Short format: "2d 3h 30m 15s" or "3:30:15"
		do
			create Result.make (15)
			if days > 0 then
				Result.append_integer (days)
				Result.append_character ('d')
				Result.append_character (' ')
			end
			Result.append_integer (hours)
			Result.append_character (':')
			if minutes < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (minutes)
			Result.append_character (':')
			if seconds < 10 then
				Result.append_character ('0')
			end
			Result.append_integer (seconds)
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation.
		do
			Result := to_human
		end

feature {SIMPLE_DURATION} -- Implementation

	total_seconds_internal: INTEGER_64
			-- Total seconds (can be negative).

invariant
	-- Duration can be negative (representing past time)

end
