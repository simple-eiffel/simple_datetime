note
	description: "Test set for simple_datetime"
	testing: "type/manual"

class
	SIMPLE_DATETIME_TEST_SET

inherit
	TEST_SET_BASE

feature -- SIMPLE_DATE Tests

	test_date_creation
		local
			d: SIMPLE_DATE
		do
			create d.make (2025, 12, 7)
			assert ("year", d.year = 2025)
			assert ("month", d.month = 12)
			assert ("day", d.day = 7)
		end

	test_date_iso8601
		local
			d: SIMPLE_DATE
		do
			create d.make (2025, 1, 15)
			assert ("iso8601", d.to_iso8601.is_equal ("2025-01-15"))
		end

	test_date_american_format
		local
			d: SIMPLE_DATE
		do
			create d.make (2025, 3, 20)
			assert ("american", d.to_american.is_equal ("03/20/2025"))
		end

	test_date_european_format
		local
			d: SIMPLE_DATE
		do
			create d.make (2025, 3, 20)
			assert ("european", d.to_european.is_equal ("20.03.2025"))
		end

	test_date_plus_days
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2025, 12, 28)
			d2 := d1.plus_days (5)
			assert ("year_crossed", d2.year = 2026)
			assert ("month", d2.month = 1)
			assert ("day", d2.day = 2)
		end

	test_date_plus_months
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2025, 11, 15)
			d2 := d1.plus_months (3)
			assert ("year", d2.year = 2026)
			assert ("month", d2.month = 2)
			assert ("day", d2.day = 15)
		end

	test_date_day_of_week
		local
			d: SIMPLE_DATE
		do
			-- December 7, 2025 is a Sunday
			create d.make (2025, 12, 7)
			assert ("sunday", d.day_of_week = 7)
			assert ("is_weekend", d.is_weekend)
		end

	test_date_weekday
		local
			d: SIMPLE_DATE
		do
			-- December 8, 2025 is a Monday
			create d.make (2025, 12, 8)
			assert ("monday", d.day_of_week = 1)
			assert ("is_weekday", d.is_weekday)
		end

	test_date_comparison
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2025, 6, 15)
			create d2.make (2025, 6, 20)
			assert ("d1_before_d2", d1.is_before (d2))
			assert ("d2_after_d1", d2.is_after (d1))
		end

	test_date_days_between
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2025, 1, 1)
			create d2.make (2025, 1, 11)
			assert ("ten_days", d1.days_between (d2) = 10)
		end

	test_date_end_of_month
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2025, 2, 10)
			d2 := d1.end_of_month
			assert ("feb_28", d2.day = 28)
		end

	test_date_leap_year
		local
			d1: SIMPLE_DATE
			d2: SIMPLE_DATE
		do
			create d1.make (2024, 2, 10)
			d2 := d1.end_of_month
			assert ("feb_29_leap", d2.day = 29)
		end

feature -- SIMPLE_TIME Tests

	test_time_creation
		local
			t: SIMPLE_TIME
		do
			create t.make (14, 30, 45)
			assert ("hour", t.hour = 14)
			assert ("minute", t.minute = 30)
			assert ("second", t.second = 45)
		end

	test_time_12hour
		local
			t: SIMPLE_TIME
		do
			create t.make (14, 30, 0)
			assert ("hour_12", t.hour_12 = 2)
			assert ("is_pm", t.is_pm)
		end

	test_time_midnight
		local
			t: SIMPLE_TIME
		do
			create t.make (0, 0, 0)
			assert ("hour_12_midnight", t.hour_12 = 12)
			assert ("is_am", t.is_am)
		end

	test_time_noon
		local
			t: SIMPLE_TIME
		do
			create t.make (12, 0, 0)
			assert ("hour_12_noon", t.hour_12 = 12)
			assert ("is_pm_noon", t.is_pm)
		end

	test_time_periods
		local
			morning: SIMPLE_TIME
			afternoon: SIMPLE_TIME
			evening: SIMPLE_TIME
		do
			create morning.make (9, 0, 0)
			create afternoon.make (14, 0, 0)
			create evening.make (20, 0, 0)
			assert ("is_morning", morning.is_morning)
			assert ("is_afternoon", afternoon.is_afternoon)
			assert ("is_evening", evening.is_evening)
		end

	test_time_iso8601
		local
			t: SIMPLE_TIME
		do
			create t.make (9, 5, 3)
			assert ("iso8601", t.to_iso8601.is_equal ("09:05:03"))
		end

	test_time_12hour_format
		local
			t: SIMPLE_TIME
		do
			create t.make (14, 30, 0)
			assert ("12hour_format", t.to_12hour.is_equal ("2:30 PM"))
		end

	test_time_plus_hours
		local
			t1: SIMPLE_TIME
			t2: SIMPLE_TIME
		do
			create t1.make (22, 0, 0)
			t2 := t1.plus_hours (5)
			assert ("wrapped", t2.hour = 3)
		end

feature -- SIMPLE_DATE_TIME Tests

	test_datetime_creation
		local
			dt: SIMPLE_DATE_TIME
		do
			create dt.make (2025, 12, 7, 14, 30, 45)
			assert ("year", dt.year = 2025)
			assert ("month", dt.month = 12)
			assert ("day", dt.day = 7)
			assert ("hour", dt.hour = 14)
			assert ("minute", dt.minute = 30)
			assert ("second", dt.second = 45)
		end

	test_datetime_iso8601
		local
			dt: SIMPLE_DATE_TIME
		do
			create dt.make (2025, 12, 7, 14, 30, 0)
			assert ("iso8601", dt.to_iso8601.is_equal ("2025-12-07T14:30:00"))
		end

	test_datetime_components
		local
			dt: SIMPLE_DATE_TIME
			d: SIMPLE_DATE
			t: SIMPLE_TIME
		do
			create dt.make (2025, 12, 7, 14, 30, 0)
			d := dt.date
			t := dt.time
			assert ("date_year", d.year = 2025)
			assert ("time_hour", t.hour = 14)
		end

feature -- SIMPLE_DURATION Tests

	test_duration_from_seconds
		local
			dur: SIMPLE_DURATION
		do
			create dur.make_seconds (3661)
			assert ("hours", dur.hours = 1)
			assert ("minutes", dur.minutes = 1)
			assert ("seconds", dur.seconds = 1)
		end

	test_duration_from_components
		local
			dur: SIMPLE_DURATION
		do
			create dur.make (2, 3, 30, 45)
			assert ("days", dur.days = 2)
			assert ("hours", dur.hours = 3)
			assert ("minutes", dur.minutes = 30)
			assert ("seconds", dur.seconds = 45)
		end

	test_duration_total_seconds
		local
			dur: SIMPLE_DURATION
		do
			create dur.make (1, 0, 0, 0)
			assert ("day_in_seconds", dur.total_seconds = 86400)
		end

	test_duration_plus
		local
			d1: SIMPLE_DURATION
			d2: SIMPLE_DURATION
			d3: SIMPLE_DURATION
		do
			create d1.make (0, 1, 30, 0)
			create d2.make (0, 0, 45, 0)
			d3 := d1.plus (d2)
			assert ("hours", d3.hours = 2)
			assert ("minutes", d3.minutes = 15)
		end

	test_duration_iso8601
		local
			dur: SIMPLE_DURATION
		do
			create dur.make (2, 3, 30, 45)
			assert ("iso8601", dur.to_iso8601.is_equal ("P2DT3H30M45S"))
		end

	test_duration_human
		local
			dur: SIMPLE_DURATION
		do
			create dur.make (0, 2, 30, 0)
			assert ("human", dur.to_human.is_equal ("2 hours, 30 minutes"))
		end

feature -- SIMPLE_AGE Tests

	test_age_creation
		local
			age: SIMPLE_AGE
		do
			create age.make (25, 6, 15)
			assert ("years", age.years = 25)
			assert ("months", age.months = 6)
			assert ("days", age.days = 15)
		end

	test_age_from_dates
		local
			birth: SIMPLE_DATE
			today: SIMPLE_DATE
			age: SIMPLE_AGE
		do
			create birth.make (2000, 1, 1)
			create today.make (2025, 6, 15)
			create age.make_from_dates (birth, today)
			assert ("years", age.years = 25)
			assert ("months", age.months = 5)
			assert ("days", age.days = 14)
		end

	test_age_adult
		local
			adult: SIMPLE_AGE
			minor: SIMPLE_AGE
		do
			create adult.make (18, 0, 0)
			create minor.make (17, 11, 29)
			assert ("is_adult", adult.is_adult)
			assert ("is_minor", minor.is_minor)
		end

	test_age_senior
		local
			senior: SIMPLE_AGE
		do
			create senior.make (65, 0, 0)
			assert ("is_senior", senior.is_senior)
		end

	test_age_teen
		local
			teen: SIMPLE_AGE
			child: SIMPLE_AGE
		do
			create teen.make (15, 0, 0)
			create child.make (10, 0, 0)
			assert ("is_teen", teen.is_teen)
			assert ("is_child", child.is_child)
		end

	test_age_thresholds
		local
			age: SIMPLE_AGE
		do
			create age.make (21, 0, 0)
			assert ("at_least_21", age.is_at_least (21))
			assert ("under_25", age.is_under (25))
			assert ("between_18_30", age.is_between (18, 30))
		end

	test_age_to_string
		local
			age: SIMPLE_AGE
		do
			create age.make (25, 3, 14)
			assert ("to_string", age.to_string.is_equal ("25 years, 3 months, 14 days"))
		end

	test_age_to_short
		local
			age: SIMPLE_AGE
		do
			create age.make (25, 3, 14)
			assert ("to_short", age.to_short.is_equal ("25y 3m 14d"))
		end

feature -- SIMPLE_DATE_RANGE Tests

	test_range_creation
		local
			start_date: SIMPLE_DATE
			end_date: SIMPLE_DATE
			range: SIMPLE_DATE_RANGE
		do
			create start_date.make (2025, 1, 1)
			create end_date.make (2025, 1, 31)
			create range.make (start_date, end_date)
			assert ("total_days", range.total_days = 31)
		end

	test_range_make_week
		local
			start_date: SIMPLE_DATE
			range: SIMPLE_DATE_RANGE
		do
			create start_date.make (2025, 1, 1)
			create range.make_week (start_date)
			assert ("seven_days", range.total_days = 7)
		end

	test_range_make_month
		local
			range: SIMPLE_DATE_RANGE
		do
			create range.make_month (2025, 2)
			assert ("feb_days", range.total_days = 28)
		end

	test_range_make_year
		local
			range: SIMPLE_DATE_RANGE
		do
			create range.make_year (2025)
			assert ("year_days", range.total_days = 365)
		end

	test_range_contains
		local
			start_date: SIMPLE_DATE
			end_date: SIMPLE_DATE
			test_date: SIMPLE_DATE
			range: SIMPLE_DATE_RANGE
		do
			create start_date.make (2025, 1, 1)
			create end_date.make (2025, 1, 31)
			create test_date.make (2025, 1, 15)
			create range.make (start_date, end_date)
			assert ("contains", range.contains (test_date))
		end

	test_range_overlaps
		local
			r1: SIMPLE_DATE_RANGE
			r2: SIMPLE_DATE_RANGE
		do
			create r1.make_month (2025, 1)
			create r2.make_month (2025, 1)
			assert ("overlaps", r1.overlaps (r2))
		end

	test_range_no_overlap
		local
			r1: SIMPLE_DATE_RANGE
			r2: SIMPLE_DATE_RANGE
		do
			create r1.make_month (2025, 1)
			create r2.make_month (2025, 3)
			assert ("no_overlap", not r1.overlaps (r2))
		end

	test_range_union
		local
			r1: SIMPLE_DATE_RANGE
			r2: SIMPLE_DATE_RANGE
			u: SIMPLE_DATE_RANGE
		do
			create r1.make_month (2025, 1)
			create r2.make_month (2025, 2)
			u := r1.union (r2)
			assert ("union_days", u.total_days = 59)
		end

	test_range_to_string
		local
			start_date: SIMPLE_DATE
			end_date: SIMPLE_DATE
			range: SIMPLE_DATE_RANGE
		do
			create start_date.make (2025, 1, 1)
			create end_date.make (2025, 1, 31)
			create range.make (start_date, end_date)
			assert ("to_string", range.to_string.is_equal ("2025-01-01 to 2025-01-31"))
		end

end
