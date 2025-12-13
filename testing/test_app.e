note
	description: "Test application for simple_datetime library"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: LIB_TESTS
		do
			create tests
			io.put_string ("simple_datetime test runner%N")
			io.put_string ("===========================%N%N")

			passed := 0
			failed := 0

			-- SIMPLE_DATE tests
			io.put_string ("SIMPLE_DATE Tests:%N")
			run_test (agent tests.test_date_creation, "test_date_creation")
			run_test (agent tests.test_date_iso8601, "test_date_iso8601")
			run_test (agent tests.test_date_american_format, "test_date_american_format")
			run_test (agent tests.test_date_european_format, "test_date_european_format")
			run_test (agent tests.test_date_plus_days, "test_date_plus_days")
			run_test (agent tests.test_date_plus_months, "test_date_plus_months")
			run_test (agent tests.test_date_day_of_week, "test_date_day_of_week")
			run_test (agent tests.test_date_weekday, "test_date_weekday")
			run_test (agent tests.test_date_comparison, "test_date_comparison")
			run_test (agent tests.test_date_days_between, "test_date_days_between")
			run_test (agent tests.test_date_end_of_month, "test_date_end_of_month")
			run_test (agent tests.test_date_leap_year, "test_date_leap_year")

			-- SIMPLE_TIME tests
			io.put_string ("%NSIMPLE_TIME Tests:%N")
			run_test (agent tests.test_time_creation, "test_time_creation")
			run_test (agent tests.test_time_12hour, "test_time_12hour")
			run_test (agent tests.test_time_midnight, "test_time_midnight")
			run_test (agent tests.test_time_noon, "test_time_noon")
			run_test (agent tests.test_time_periods, "test_time_periods")
			run_test (agent tests.test_time_iso8601, "test_time_iso8601")
			run_test (agent tests.test_time_12hour_format, "test_time_12hour_format")
			run_test (agent tests.test_time_plus_hours, "test_time_plus_hours")

			-- SIMPLE_DATE_TIME tests
			io.put_string ("%NSIMPLE_DATE_TIME Tests:%N")
			run_test (agent tests.test_datetime_creation, "test_datetime_creation")
			run_test (agent tests.test_datetime_iso8601, "test_datetime_iso8601")
			run_test (agent tests.test_datetime_components, "test_datetime_components")

			-- SIMPLE_DURATION tests
			io.put_string ("%NSIMPLE_DURATION Tests:%N")
			run_test (agent tests.test_duration_from_seconds, "test_duration_from_seconds")
			run_test (agent tests.test_duration_from_components, "test_duration_from_components")
			run_test (agent tests.test_duration_total_seconds, "test_duration_total_seconds")
			run_test (agent tests.test_duration_plus, "test_duration_plus")
			run_test (agent tests.test_duration_iso8601, "test_duration_iso8601")
			run_test (agent tests.test_duration_human, "test_duration_human")

			-- SIMPLE_AGE tests
			io.put_string ("%NSIMPLE_AGE Tests:%N")
			run_test (agent tests.test_age_creation, "test_age_creation")
			run_test (agent tests.test_age_from_dates, "test_age_from_dates")
			run_test (agent tests.test_age_adult, "test_age_adult")
			run_test (agent tests.test_age_senior, "test_age_senior")
			run_test (agent tests.test_age_teen, "test_age_teen")
			run_test (agent tests.test_age_thresholds, "test_age_thresholds")
			run_test (agent tests.test_age_to_string, "test_age_to_string")
			run_test (agent tests.test_age_to_short, "test_age_to_short")

			-- SIMPLE_DATE_RANGE tests
			io.put_string ("%NSIMPLE_DATE_RANGE Tests:%N")
			run_test (agent tests.test_range_creation, "test_range_creation")
			run_test (agent tests.test_range_make_week, "test_range_make_week")
			run_test (agent tests.test_range_make_month, "test_range_make_month")
			run_test (agent tests.test_range_make_year, "test_range_make_year")
			run_test (agent tests.test_range_contains, "test_range_contains")
			run_test (agent tests.test_range_overlaps, "test_range_overlaps")
			run_test (agent tests.test_range_no_overlap, "test_range_no_overlap")
			run_test (agent tests.test_range_union, "test_range_union")
			run_test (agent tests.test_range_to_string, "test_range_to_string")

			io.put_string ("%N===========================%N")
			io.put_string ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
