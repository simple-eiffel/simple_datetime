note
	description: "[
		Simple Date Range - Represents a range/interval between two dates.

		Provides iteration, containment checking, overlap detection, and
		business day calculations for date ranges.

		This is an innovative first-class feature - most datetime libraries
		treat ranges as an afterthought.

		Example:
			range := create {SIMPLE_DATE_RANGE}.make (start_date, end_date)
			print (range.total_days)              -- 30
			print (range.business_days)           -- 22
			print (range.contains (some_date))    -- True
			across range as d loop
				print (d.item.to_iso8601)
			end
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DATE_RANGE

inherit
	ITERABLE [SIMPLE_DATE]
		redefine
			out
		end

	MML_MODEL
		undefine
			out
		end

create
	make,
	make_week,
	make_month,
	make_year

feature {NONE} -- Initialization

	make (a_start, a_end: SIMPLE_DATE)
			-- Create range from `a_start' to `a_end'.
			-- Automatically normalizes so start_date <= end_date.
		do
			if a_start.is_before (a_end) or a_start.is_equal (a_end) then
				start_date := a_start
				end_date := a_end
			else
				-- Swap if start is after end
				start_date := a_end
				end_date := a_start
			end
		ensure
			ordered: start_date.is_before (end_date) or start_date.is_equal (end_date)
			covers_start: contains (a_start)
			covers_end: contains (a_end)
			model_count: date_interval.count = total_days
		end

	make_week (a_start: SIMPLE_DATE)
			-- Create a 7-day range starting from `a_start'.
		do
			start_date := a_start
			end_date := a_start.plus_days (6)
		ensure
			seven_days: total_days = 7
			starts_at: start_date.is_equal (a_start)
			model_count: date_interval.count = 7
		end

	make_month (a_year, a_month: INTEGER)
			-- Create range for entire month.
		require
			valid_month: a_month >= 1 and a_month <= 12
		do
			create start_date.make (a_year, a_month, 1)
			end_date := start_date.end_of_month
		ensure
			correct_start: start_date.year = a_year and start_date.month = a_month and start_date.day = 1
			correct_end: end_date.month = a_month and end_date.year = a_year
			model_count: date_interval.count = total_days
		end

	make_year (a_year: INTEGER)
			-- Create range for entire year.
		do
			create start_date.make (a_year, 1, 1)
			create end_date.make (a_year, 12, 31)
		ensure
			correct_start: start_date.year = a_year and start_date.month = 1 and start_date.day = 1
			correct_end: end_date.year = a_year and end_date.month = 12 and end_date.day = 31
			leap_year_days: start_date.is_leap_year implies total_days = 366
			normal_year_days: not start_date.is_leap_year implies total_days = 365
		end

feature -- Access

	start_date: SIMPLE_DATE
			-- Start of range (inclusive).

	end_date: SIMPLE_DATE
			-- End of range (inclusive).

feature -- Model Query (MML)

	date_interval: MML_INTERVAL
			-- Model query: range as MML_INTERVAL of day numbers.
			-- Uses internal DATE.days for consistent day numbering.
		do
			create Result.from_range (start_date.internal_date.days, end_date.internal_date.days)
		ensure
			correct_count: Result.count = total_days
			not_empty: not Result.is_empty
			lower_matches: Result.lower = start_date.internal_date.days
			upper_matches: Result.upper = end_date.internal_date.days
		end

	day_number (a_date: SIMPLE_DATE): INTEGER
			-- Model helper: convert date to day number for interval operations.
		do
			Result := a_date.internal_date.days
		end

feature -- Comparison (MML_MODEL implementation)

	is_model_equal alias "|=|" (other: MML_MODEL): BOOLEAN
			-- Does this date range model equal `other'?
			-- Two date ranges are model-equal iff they cover the same interval.
		do
			if attached {SIMPLE_DATE_RANGE} other as other_range then
				Result := date_interval |=| other_range.date_interval
			end
		ensure then
			same_interval: attached {SIMPLE_DATE_RANGE} other as r implies (Result = (date_interval |=| r.date_interval))
		end

feature -- Measurement

	total_days: INTEGER
			-- Total number of days in range (inclusive).
		do
			Result := end_date.days_between (start_date).abs + 1
		ensure
			positive: Result >= 1
		end

	total_weeks: INTEGER
			-- Number of complete weeks.
		do
			Result := total_days // 7
		end

	business_days: INTEGER
			-- Number of business days (weekdays) in range.
		local
			l_current: SIMPLE_DATE
		do
			from
				l_current := start_date
			until
				l_current.is_after (end_date)
			loop
				if l_current.is_weekday then
					Result := Result + 1
				end
				l_current := l_current.plus_days (1)
			end
		ensure
			non_negative: Result >= 0
			not_more_than_total: Result <= total_days
		end

	weekend_days: INTEGER
			-- Number of weekend days in range.
		do
			Result := total_days - business_days
		ensure
			non_negative: Result >= 0
		end

feature -- Status

	contains (a_date: SIMPLE_DATE): BOOLEAN
			-- Is `a_date' within this range (inclusive)?
		do
			Result := (a_date.is_after (start_date) or a_date.is_equal (start_date)) and
				(a_date.is_before (end_date) or a_date.is_equal (end_date))
		ensure
			model_definition: Result = date_interval.has (day_number (a_date))
		end

	contains_today: BOOLEAN
			-- Does this range contain today?
		local
			l_today: SIMPLE_DATE
		do
			create l_today.make_now
			Result := contains (l_today)
		end

	overlaps (other: SIMPLE_DATE_RANGE): BOOLEAN
			-- Does this range overlap with `other'?
			-- Two ranges overlap iff their intersection is non-empty.
		do
			Result := contains (other.start_date) or contains (other.end_date) or
				other.contains (start_date) or other.contains (end_date)
		ensure
			model_definition: Result = not (date_interval * other.date_interval).is_empty
			symmetric: Result = other.overlaps (Current)
		end

	is_adjacent (other: SIMPLE_DATE_RANGE): BOOLEAN
			-- Is this range adjacent to `other' (no gap, no overlap)?
		do
			Result := end_date.plus_days (1).is_equal (other.start_date) or
				other.end_date.plus_days (1).is_equal (start_date)
		ensure
			model_no_overlap: Result implies not overlaps (other)
			model_no_gap: Result implies (date_interval.upper + 1 = other.date_interval.lower or
				other.date_interval.upper + 1 = date_interval.lower)
			symmetric: Result = other.is_adjacent (Current)
		end

	is_past: BOOLEAN
			-- Is this entire range in the past?
		local
			l_today: SIMPLE_DATE
		do
			create l_today.make_now
			Result := end_date.is_before (l_today)
		end

	is_future: BOOLEAN
			-- Is this entire range in the future?
		local
			l_today: SIMPLE_DATE
		do
			create l_today.make_now
			Result := start_date.is_after (l_today)
		end

	is_current: BOOLEAN
			-- Does this range span today?
		do
			Result := contains_today
		end

	is_empty: BOOLEAN
			-- Is this a single-day range?
		do
			Result := start_date.is_equal (end_date)
		end

feature -- Operations

	intersection (other: SIMPLE_DATE_RANGE): detachable SIMPLE_DATE_RANGE
			-- Intersection of this range with `other', or Void if no overlap.
		local
			l_start, l_end: SIMPLE_DATE
		do
			if overlaps (other) then
				-- Start is the later of the two starts
				if start_date.is_after (other.start_date) then
					l_start := start_date
				else
					l_start := other.start_date
				end

				-- End is the earlier of the two ends
				if end_date.is_before (other.end_date) then
					l_end := end_date
				else
					l_end := other.end_date
				end

				create Result.make (l_start, l_end)
			end
		ensure
			void_when_disjoint: not overlaps (other) implies Result = Void
			attached_when_overlap: overlaps (other) implies Result /= Void
			result_subset_of_self: attached Result as r implies (r.date_interval <= date_interval)
			result_subset_of_other: attached Result as r implies (r.date_interval <= other.date_interval)
			model_definition: attached Result as r implies (r.date_interval |=| (date_interval * other.date_interval))
		end

	union (other: SIMPLE_DATE_RANGE): SIMPLE_DATE_RANGE
			-- Union of this range with `other' (smallest contiguous range containing both).
			-- Note: Returns hull (bounding box), not strict set union.
		local
			l_start, l_end: SIMPLE_DATE
		do
			-- Start is the earlier of the two starts
			if start_date.is_before (other.start_date) then
				l_start := start_date
			else
				l_start := other.start_date
			end

			-- End is the later of the two ends
			if end_date.is_after (other.end_date) then
				l_end := end_date
			else
				l_end := other.end_date
			end

			create Result.make (l_start, l_end)
		ensure
			contains_this: Result.contains (start_date) and Result.contains (end_date)
			contains_other: Result.contains (other.start_date) and Result.contains (other.end_date)
			model_superset_of_self: date_interval <= Result.date_interval
			model_superset_of_other: other.date_interval <= Result.date_interval
			model_hull: Result.date_interval |=| (date_interval |+| other.date_interval)
			symmetric: Result.date_interval |=| other.union (Current).date_interval
		end

	expanded_by (a_days: INTEGER): SIMPLE_DATE_RANGE
			-- Range expanded by `a_days' on each end.
		require
			non_negative: a_days >= 0
		do
			create Result.make (start_date.minus_days (a_days), end_date.plus_days (a_days))
		ensure
			covers_original: date_interval <= Result.date_interval
			expanded_days: Result.total_days = total_days + (2 * a_days)
		end

	shifted_by (a_days: INTEGER): SIMPLE_DATE_RANGE
			-- Range shifted by `a_days' (positive = future, negative = past).
		do
			create Result.make (start_date.plus_days (a_days), end_date.plus_days (a_days))
		ensure
			same_duration: Result.total_days = total_days
			model_count_preserved: Result.date_interval.count = date_interval.count
			shifted_lower: Result.date_interval.lower = date_interval.lower + a_days
			shifted_upper: Result.date_interval.upper = date_interval.upper + a_days
		end

feature -- Iteration

	new_cursor: SIMPLE_DATE_RANGE_CURSOR
			-- Fresh cursor for iteration.
		do
			create Result.make (start_date, end_date)
		end

	dates: ARRAYED_LIST [SIMPLE_DATE]
			-- All dates in range as a list.
		local
			l_current: SIMPLE_DATE
		do
			create Result.make (total_days)
			from
				l_current := start_date
			until
				l_current.is_after (end_date)
			loop
				Result.extend (l_current)
				l_current := l_current.plus_days (1)
			end
		ensure
			correct_count: Result.count = total_days
			model_count: Result.count = date_interval.count
			all_contained: across Result as ic all contains (ic) end
		end

	weekdays: ARRAYED_LIST [SIMPLE_DATE]
			-- Only weekdays in range as a list.
		local
			l_current: SIMPLE_DATE
		do
			create Result.make (business_days)
			from
				l_current := start_date
			until
				l_current.is_after (end_date)
			loop
				if l_current.is_weekday then
					Result.extend (l_current)
				end
				l_current := l_current.plus_days (1)
			end
		ensure
			correct_count: Result.count = business_days
			all_contained: across Result as ic all contains (ic) end
			all_weekdays: across Result as ic all ic.is_weekday end
		end

	weekends: ARRAYED_LIST [SIMPLE_DATE]
			-- Only weekend days in range as a list.
		local
			l_current: SIMPLE_DATE
		do
			create Result.make (weekend_days)
			from
				l_current := start_date
			until
				l_current.is_after (end_date)
			loop
				if l_current.is_weekend then
					Result.extend (l_current)
				end
				l_current := l_current.plus_days (1)
			end
		ensure
			correct_count: Result.count = weekend_days
			all_contained: across Result as ic all contains (ic) end
			all_weekends: across Result as ic all ic.is_weekend end
			partition: Result.count + weekdays.count = total_days
		end

feature -- Output

	to_string: STRING
			-- String representation: "2025-01-01 to 2025-01-31"
		do
			create Result.make (25)
			Result.append (start_date.to_iso8601)
			Result.append_string (" to ")
			Result.append (end_date.to_iso8601)
		ensure
			result_attached: Result /= Void
		end

	to_human: STRING
			-- Human-readable: "January 1, 2025 - January 31, 2025"
		do
			create Result.make (50)
			Result.append (start_date.to_human)
			Result.append_string (" - ")
			Result.append (end_date.to_human)
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation.
		do
			Result := to_string
		end

invariant
	ordered: start_date.is_before (end_date) or start_date.is_equal (end_date)
	positive_duration: total_days >= 1
	model_interval_valid: not date_interval.is_empty
	model_bounds: date_interval.lower = start_date.internal_date.days and
		date_interval.upper = end_date.internal_date.days
	contains_endpoints: contains (start_date) and contains (end_date)

end
