note
	description: "[
		Simple Monotonic Clock - a high-resolution elapsed-time clock.

		Wraps the Windows performance counter (QueryPerformanceCounter). The
		value is a count from an arbitrary starting point: it never goes
		backwards and is not affected by changes to the wall clock, so it is
		for measuring elapsed time, not for telling the date.

		Example:
			start := clock.nanoseconds
			-- ... work ...
			elapsed_ms := clock.elapsed_milliseconds (start)
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_MONOTONIC_CLOCK

feature -- Access

	ticks: INTEGER_64
			-- Raw performance counter value.
		do
			Result := c_counter
		ensure
			non_negative: Result >= 0
		end

	ticks_per_second: INTEGER_64
			-- Counter frequency (ticks in one second).
		do
			Result := c_frequency
		ensure
			positive: Result > 0
		end

	nanoseconds: INTEGER_64
			-- Time since the clock's arbitrary origin, in nanoseconds.
		do
			Result := to_nanoseconds (ticks, ticks_per_second)
		ensure
			non_negative: Result >= 0
		end

	microseconds: INTEGER_64
			-- Time since the clock's arbitrary origin, in microseconds.
		do
			Result := nanoseconds // 1000
		ensure
			non_negative: Result >= 0
		end

	milliseconds: INTEGER_64
			-- Time since the clock's arbitrary origin, in milliseconds.
		do
			Result := nanoseconds // 1000000
		ensure
			non_negative: Result >= 0
		end

feature -- Measurement

	elapsed_nanoseconds (a_start: INTEGER_64): INTEGER_64
			-- Nanoseconds since `a_start' (a value earlier read from `nanoseconds').
		require
			start_not_negative: a_start >= 0
		do
			Result := nanoseconds - a_start
		ensure
			not_before_start: Result >= 0
		end

	elapsed_milliseconds (a_start: INTEGER_64): INTEGER_64
			-- Whole milliseconds since `a_start' (a value earlier read from `nanoseconds').
		require
			start_not_negative: a_start >= 0
		do
			Result := elapsed_nanoseconds (a_start) // 1000000
		ensure
			not_negative: Result >= 0
		end

feature -- Conversion

	to_nanoseconds (a_ticks, a_frequency: INTEGER_64): INTEGER_64
			-- `a_ticks' at `a_frequency' ticks per second, in nanoseconds,
			-- split into whole seconds and remainder so the remainder product cannot overflow
			-- (the result itself holds about 292 years of nanoseconds).
		require
			ticks_not_negative: a_ticks >= 0
			frequency_positive: a_frequency > 0
		do
			Result := (a_ticks // a_frequency) * 1000000000 + ((a_ticks \\ a_frequency) * 1000000000) // a_frequency
		ensure
			not_negative: Result >= 0
		end

feature {NONE} -- Implementation

	c_counter: INTEGER_64
			-- Current QueryPerformanceCounter value.
		external
			"C inline use <windows.h>"
		alias
			"[
				LARGE_INTEGER li;
				QueryPerformanceCounter(&li);
				return (EIF_INTEGER_64) li.QuadPart;
			]"
		end

	c_frequency: INTEGER_64
			-- QueryPerformanceFrequency value.
		external
			"C inline use <windows.h>"
		alias
			"[
				LARGE_INTEGER li;
				QueryPerformanceFrequency(&li);
				return (EIF_INTEGER_64) li.QuadPart;
			]"
		end

end
