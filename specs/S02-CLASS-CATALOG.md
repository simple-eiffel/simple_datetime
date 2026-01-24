# S02-CLASS-CATALOG.md
## simple_datetime - Class Catalog

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Class Hierarchy

```
COMPARABLE
    |
    +-- SIMPLE_DATE
    +-- SIMPLE_TIME
    +-- SIMPLE_DATE_TIME

SIMPLE_DATETIME (facade - no inheritance)

SIMPLE_DURATION (standalone)

SIMPLE_AGE (standalone)

SIMPLE_DATE_RANGE (standalone)
    |
    +-- SIMPLE_DATE_RANGE_CURSOR (iterator)
```

## 2. Class Descriptions

### 2.1 SIMPLE_DATETIME (Facade)

**Purpose:** Factory class providing creation methods and utilities.

**Creation:** `make`

**Factory Methods - Current Time:**
- `now`, `current_time`, `current_datetime`, `timestamp`: SIMPLE_DATE_TIME
- `utc_now`, `utc_timestamp`, `current_utc`: SIMPLE_DATE_TIME
- `today`, `current_date`, `todays_date`: SIMPLE_DATE
- `tomorrow`: SIMPLE_DATE
- `yesterday`: SIMPLE_DATE

**Factory Methods - Creation:**
- `date`, `new_date`, `make_date`, `create_date (year, month, day)`: SIMPLE_DATE
- `time`, `new_time`, `make_time`, `create_time (hour, minute, second)`: SIMPLE_TIME
- `datetime`, `new_datetime`, `make_datetime`, `create_datetime (y, m, d, h, m, s)`: SIMPLE_DATE_TIME

**Parsing:**
- `parse_date`, `decode_date`, `date_from_string`, `string_to_date (STRING)`: SIMPLE_DATE
- `parse_datetime`, `decode_datetime`, `datetime_from_string`, `string_to_datetime (STRING)`: SIMPLE_DATE_TIME
- `parse_iso8601`, `decode_iso8601`, `from_iso8601`, `iso_to_datetime (STRING)`: SIMPLE_DATE_TIME

**Relative Dates:**
- `next_monday`, `next_tuesday`, `next_wednesday`, `next_thursday`, `next_friday`: SIMPLE_DATE
- `last_monday`, `last_friday`: SIMPLE_DATE
- `first_of_month`, `last_of_month`, `first_of_next_month`: SIMPLE_DATE
- `first_of_year`, `last_of_year`: SIMPLE_DATE

**Age Calculation:**
- `age_from (birthdate)`: SIMPLE_AGE
- `age_between (start, end)`: SIMPLE_AGE

**Business Days:**
- `add_business_days (date, days)`: SIMPLE_DATE
- `business_days_between (start, end)`: INTEGER
- `is_business_day (date)`: BOOLEAN
- `next_business_day (date)`: SIMPLE_DATE

**Duration:**
- `duration`: SIMPLE_DURATION
- `days (count)`, `hours (count)`, `minutes (count)`: SIMPLE_DURATION

**Human-Friendly:**
- `time_ago (datetime)`: STRING
- `time_until (datetime)`: STRING

**Ranges:**
- `date_range (start, end)`: SIMPLE_DATE_RANGE

---

### 2.2 SIMPLE_DATE

**Purpose:** High-level wrapper over Eiffel's DATE class.

**Creation:**
- `make (year, month, day)`
- `make_now`
- `make_from_string (STRING)`
- `make_from_date (DATE)`

**Access:**
- `year`, `month`, `day`: INTEGER
- `day_of_week`, `day_of_year`, `week_of_year`, `quarter`: INTEGER

**Status:**
- `is_leap_year`, `is_weekend`, `is_weekday`: BOOLEAN
- `is_today`, `is_past`, `is_future`: BOOLEAN

**Comparison:**
- `is_before`, `is_after`, `is_equal`, `is_less (<)`: BOOLEAN
- `days_between (other)`: INTEGER

**Arithmetic:**
- `plus_days`, `minus_days`, `plus_weeks`, `plus_months`, `minus_months`, `plus_years`: SIMPLE_DATE

**Business Days:**
- `plus_business_days (days)`: SIMPLE_DATE
- `business_days_until (other)`: INTEGER

**Navigation:**
- `start_of_month`, `end_of_month`, `start_of_year`, `end_of_year`: SIMPLE_DATE
- `next_weekday (1-7)`, `previous_weekday (1-7)`: SIMPLE_DATE

**Output:**
- `to_iso8601`, `to_iso_compact`: STRING
- `to_american`, `to_european`: STRING
- `to_human`, `to_human_short`: STRING
- `month_name`, `month_name_short`, `weekday_name`, `weekday_name_short`: STRING

**Conversion:**
- `to_date`: DATE
- `to_datetime (time)`: SIMPLE_DATE_TIME
- `at_midnight`, `at_noon`, `at_end_of_day`: SIMPLE_DATE_TIME

---

### 2.3 SIMPLE_TIME

**Purpose:** High-level wrapper over Eiffel's TIME class.

**Creation:**
- `make (hour, minute, second)`
- `make_now`
- `make_from_string (STRING)`
- `make_from_time (TIME)`
- `make_from_seconds (INTEGER)`

**Access:**
- `hour`, `minute`, `second`: INTEGER
- `hour_12`: INTEGER (1-12)
- `seconds_since_midnight`: INTEGER

**Status:**
- `is_am`, `is_pm`: BOOLEAN
- `is_midnight`, `is_noon`: BOOLEAN
- `is_morning`, `is_afternoon`, `is_evening`: BOOLEAN

**Arithmetic:**
- `plus_hours`, `minus_hours`: SIMPLE_TIME
- `plus_minutes`, `minus_minutes`: SIMPLE_TIME
- `plus_seconds`, `minus_seconds`: SIMPLE_TIME

**Output:**
- `to_iso8601`, `to_iso_compact`, `to_short`: STRING
- `to_12hour`, `to_12hour_with_seconds`: STRING

---

### 2.4 SIMPLE_DATE_TIME

**Purpose:** Combined date and time with timezone support.

**Creation:**
- `make (year, month, day, hour, minute, second)`
- `make_now`, `make_now_utc`
- `make_from_string`, `make_from_iso8601`, `make_from_timestamp`, `make_from_date_time`

**Access:**
- `year`, `month`, `day`, `day_of_week`, `day_of_year`: INTEGER
- `hour`, `minute`, `second`: INTEGER
- `date`: SIMPLE_DATE
- `time`: SIMPLE_TIME
- `is_utc`: BOOLEAN

**Arithmetic:**
- `plus_days`, `minus_days`: SIMPLE_DATE_TIME
- `plus_hours`, `minus_hours`: SIMPLE_DATE_TIME
- `plus_minutes`, `minus_minutes`: SIMPLE_DATE_TIME
- `plus_seconds`: SIMPLE_DATE_TIME

**Output:**
- `to_iso8601`, `to_iso8601_utc`, `to_iso8601_date`: STRING
- `to_human`, `to_human_short`: STRING
- `time_ago`, `time_until`: STRING

**Conversion:**
- `to_date_time`: DATE_TIME
- `to_timestamp`: INTEGER_64

---

### 2.5 SIMPLE_DURATION

**Purpose:** Time span representation.

**Creation:**
- `make_zero`
- `make_days`, `make_hours`, `make_minutes`, `make_seconds`

---

### 2.6 SIMPLE_AGE

**Purpose:** Specialized age calculation.

**Creation:**
- `make_from_dates (start, end)`

**Access:**
- `years`, `months`, `days`: INTEGER
- `total_days`: INTEGER

---

### 2.7 SIMPLE_DATE_RANGE

**Purpose:** Date interval with iteration support.

**Creation:**
- `make (start, end)`

**Access:**
- `start_date`, `end_date`: SIMPLE_DATE
- `contains (date)`: BOOLEAN
- `business_days_count`: INTEGER
