note
	description: "[
		Simple Age - Specialized class for age calculation.

		Provides accurate age calculation in years, months, and days,
		handling edge cases like leap years and varying month lengths.

		This is an innovative feature not commonly found in datetime
		libraries - most force developers to calculate age manually.

		Example:
			birthdate := create {SIMPLE_DATE}.make (1990, 3, 15)
			age := create {SIMPLE_AGE}.make_from_dates (birthdate, today)
			print (age.years)           -- 35
			print (age.to_string)       -- "35 years, 8 months, 22 days"
			print (age.is_adult)        -- True
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_AGE

inherit
	ANY
		redefine
			out
		end

create
	make_from_dates,
	make_from_birthdate,
	make

feature {NONE} -- Initialization

	make_from_dates (a_start, a_end: SIMPLE_DATE)
			-- Create age from `a_start' to `a_end'.
		require
			start_not_void: a_start /= Void
			end_not_void: a_end /= Void
			start_not_after_end: a_start.is_before (a_end) or a_start.is_equal (a_end)
		local
			l_years, l_months, l_days: INTEGER
			l_start_year, l_start_month, l_start_day: INTEGER
			l_end_year, l_end_month, l_end_day: INTEGER
			l_days_in_prev_month: INTEGER
		do
			start_date := a_start
			end_date := a_end

			l_start_year := a_start.year
			l_start_month := a_start.month
			l_start_day := a_start.day

			l_end_year := a_end.year
			l_end_month := a_end.month
			l_end_day := a_end.day

			-- Calculate days, borrowing from months if needed
			l_days := l_end_day - l_start_day
			if l_days < 0 then
				-- Borrow from previous month
				l_end_month := l_end_month - 1
				if l_end_month = 0 then
					l_end_month := 12
					l_end_year := l_end_year - 1
				end
				l_days_in_prev_month := days_in_month (l_end_year, l_end_month)
				l_days := l_days + l_days_in_prev_month
			end

			-- Calculate months, borrowing from years if needed
			l_months := l_end_month - l_start_month
			if l_months < 0 then
				l_months := l_months + 12
				l_end_year := l_end_year - 1
			end

			-- Calculate years
			l_years := l_end_year - l_start_year

			internal_years := l_years
			internal_months := l_months
			internal_days := l_days
		ensure
			start_date_set: start_date = a_start
			end_date_set: end_date = a_end
		end

	make_from_birthdate (a_birthdate: SIMPLE_DATE)
			-- Create age from `a_birthdate' to today.
		require
			birthdate_not_void: a_birthdate /= Void
			birthdate_not_future: a_birthdate.is_past or a_birthdate.is_today
		local
			l_today: SIMPLE_DATE
		do
			create l_today.make_now
			make_from_dates (a_birthdate, l_today)
		end

	make (a_years, a_months, a_days: INTEGER)
			-- Create age with specific components.
		require
			years_non_negative: a_years >= 0
			months_valid: a_months >= 0 and a_months < 12
			days_valid: a_days >= 0 and a_days < 31
		do
			internal_years := a_years
			internal_months := a_months
			internal_days := a_days
			-- Create dummy dates
			create start_date.make_now
			end_date := start_date
		ensure
			years_set: years = a_years
			months_set: months = a_months
			days_set: days = a_days
		end

feature -- Access: Components

	years: INTEGER
			-- Number of complete years.
		do
			Result := internal_years
		ensure
			non_negative: Result >= 0
		end

	months: INTEGER
			-- Number of complete months (0-11).
		do
			Result := internal_months
		ensure
			valid_range: Result >= 0 and Result < 12
		end

	days: INTEGER
			-- Number of remaining days (0-30).
		do
			Result := internal_days
		ensure
			valid_range: Result >= 0 and Result < 31
		end

feature -- Access: Totals

	total_months: INTEGER
			-- Total months (years * 12 + months).
		do
			Result := years * 12 + months
		end

	total_days: INTEGER
			-- Approximate total days.
			-- Note: Uses 365.25 days/year, 30.44 days/month for approximation.
		do
			Result := (years.to_real * 365.25 + months.to_real * 30.44 + days.to_real).truncated_to_integer
		end

	total_weeks: INTEGER
			-- Approximate total weeks.
		do
			Result := total_days // 7
		end

feature -- Access: Dates

	start_date: SIMPLE_DATE
			-- Start date (e.g., birthdate).

	end_date: SIMPLE_DATE
			-- End date (e.g., current date).

feature -- Status: Legal Age Thresholds

	is_adult: BOOLEAN
			-- Is this age 18 or older? (Common legal adult threshold)
		do
			Result := years >= 18
		end

	is_minor: BOOLEAN
			-- Is this age under 18?
		do
			Result := years < 18
		end

	is_senior: BOOLEAN
			-- Is this age 65 or older? (Common senior threshold)
		do
			Result := years >= 65
		end

	is_teen: BOOLEAN
			-- Is this age between 13 and 19?
		do
			Result := years >= 13 and years <= 19
		end

	is_child: BOOLEAN
			-- Is this age under 13?
		do
			Result := years < 13
		end

feature -- Status: Custom Thresholds

	is_at_least (a_years: INTEGER): BOOLEAN
			-- Is this age at least `a_years' years?
		require
			years_non_negative: a_years >= 0
		do
			Result := years >= a_years
		end

	is_under (a_years: INTEGER): BOOLEAN
			-- Is this age under `a_years' years?
		require
			years_positive: a_years > 0
		do
			Result := years < a_years
		end

	is_between (a_min_years, a_max_years: INTEGER): BOOLEAN
			-- Is this age between `a_min_years' and `a_max_years' (inclusive)?
		require
			valid_range: a_min_years <= a_max_years
		do
			Result := years >= a_min_years and years <= a_max_years
		end

feature -- Output

	to_string: STRING
			-- Full representation: "25 years, 3 months, 14 days"
		do
			create Result.make (40)

			if years = 1 then
				Result.append_string ("1 year")
			else
				Result.append_integer (years)
				Result.append_string (" years")
			end

			Result.append_string (", ")

			if months = 1 then
				Result.append_string ("1 month")
			else
				Result.append_integer (months)
				Result.append_string (" months")
			end

			Result.append_string (", ")

			if days = 1 then
				Result.append_string ("1 day")
			else
				Result.append_integer (days)
				Result.append_string (" days")
			end
		ensure
			result_attached: Result /= Void
		end

	to_short: STRING
			-- Short representation: "25y 3m 14d"
		do
			create Result.make (15)
			Result.append_integer (years)
			Result.append_character ('y')
			Result.append_character (' ')
			Result.append_integer (months)
			Result.append_character ('m')
			Result.append_character (' ')
			Result.append_integer (days)
			Result.append_character ('d')
		ensure
			result_attached: Result /= Void
		end

	to_years_only: STRING
			-- Years only: "25 years" or "25 years old"
		do
			create Result.make (15)
			if years = 1 then
				Result.append_string ("1 year")
			else
				Result.append_integer (years)
				Result.append_string (" years")
			end
		ensure
			result_attached: Result /= Void
		end

	to_human: STRING
			-- Human-friendly approximation: "25 years old", "6 months old", "2 weeks old"
		do
			create Result.make (20)
			if years > 0 then
				if years = 1 then
					Result.append_string ("1 year old")
				else
					Result.append_integer (years)
					Result.append_string (" years old")
				end
			elseif months > 0 then
				if months = 1 then
					Result.append_string ("1 month old")
				else
					Result.append_integer (months)
					Result.append_string (" months old")
				end
			elseif days >= 7 then
				if days // 7 = 1 then
					Result.append_string ("1 week old")
				else
					Result.append_integer (days // 7)
					Result.append_string (" weeks old")
				end
			else
				if days = 1 then
					Result.append_string ("1 day old")
				else
					Result.append_integer (days)
					Result.append_string (" days old")
				end
			end
		ensure
			result_attached: Result /= Void
		end

	out: STRING
			-- Default string representation.
		do
			Result := to_string
		end

feature {NONE} -- Implementation

	internal_years: INTEGER
			-- Stored years component.

	internal_months: INTEGER
			-- Stored months component.

	internal_days: INTEGER
			-- Stored days component.

	days_in_month (a_year, a_month: INTEGER): INTEGER
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
				if is_leap_year (a_year) then
					Result := 29
				else
					Result := 28
				end
			end
		ensure
			valid_range: Result >= 28 and Result <= 31
		end

	is_leap_year (a_year: INTEGER): BOOLEAN
			-- Is `a_year' a leap year?
		do
			Result := (a_year \\ 4 = 0 and a_year \\ 100 /= 0) or (a_year \\ 400 = 0)
		end

invariant
	years_non_negative: years >= 0
	months_valid: months >= 0 and months < 12
	days_valid: days >= 0 and days < 31
	start_date_attached: start_date /= Void
	end_date_attached: end_date /= Void

end
