# S03-CONTRACTS.md
## simple_datetime - Contracts Specification

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. SIMPLE_DATETIME Contracts

### Factory Methods
```eiffel
-- date, time, datetime creation
require
    valid_month: a_month >= 1 and a_month <= 12
    valid_day: a_day >= 1 and a_day <= 31
    valid_hour: a_hour >= 0 and a_hour <= 23
    valid_minute: a_minute >= 0 and a_minute <= 59
    valid_second: a_second >= 0 and a_second <= 59
ensure
    result_attached: Result /= Void
```

### Parsing
```eiffel
require
    string_not_empty: a_string /= Void and then not a_string.is_empty
ensure
    result_attached: Result /= Void
```

### Relative Dates
```eiffel
-- next_monday
ensure
    result_attached: Result /= Void
    is_monday: Result.day_of_week = 1
```

### Age Calculation
```eiffel
-- age_from
require
    birthdate_not_void: a_birthdate /= Void
    birthdate_in_past: a_birthdate.is_before (today) or a_birthdate.is_equal (today)
ensure
    result_attached: Result /= Void
```

### Business Days
```eiffel
-- add_business_days
require
    date_not_void: a_date /= Void
    days_positive: a_days >= 0
ensure
    result_attached: Result /= Void
```

---

## 2. SIMPLE_DATE Contracts

### Creation
```eiffel
-- make
require
    valid_month: a_month >= 1 and a_month <= 12
    valid_day: a_day >= 1 and a_day <= 31
ensure
    year_set: year = a_year
    month_set: month = a_month
    day_set: day = a_day

-- make_from_string
require
    string_not_empty: a_string /= Void and then not a_string.is_empty
```

### Access Postconditions
```eiffel
-- day_of_week
ensure
    valid_range: Result >= 1 and Result <= 7

-- day_of_year
ensure
    valid_range: Result >= 1 and Result <= 366

-- week_of_year
ensure
    valid_range: Result >= 1 and Result <= 53

-- quarter
ensure
    valid_range: Result >= 1 and Result <= 4
```

### Comparison
```eiffel
-- is_before, is_after, days_between
require
    other_not_void: other /= Void
```

### Arithmetic
```eiffel
-- plus_days, minus_days, etc.
ensure
    result_attached: Result /= Void
```

### Navigation
```eiffel
-- next_weekday
require
    valid_weekday: a_weekday >= 1 and a_weekday <= 7
ensure
    result_attached: Result /= Void
    correct_weekday: Result.day_of_week = a_weekday
    is_future: Result > Current

-- start_of_month
ensure
    result_attached: Result /= Void
    is_first: Result.day = 1
    same_month: Result.month = month
    same_year: Result.year = year
```

### Output
```eiffel
-- to_iso8601
ensure
    result_attached: Result /= Void
    correct_length: Result.count = 10
```

### Class Invariants
```eiffel
invariant
    internal_date_attached: internal_date /= Void
    valid_month: month >= 1 and month <= 12
    valid_day: day >= 1 and day <= 31
```

---

## 3. SIMPLE_TIME Contracts

### Creation
```eiffel
-- make
require
    valid_hour: a_hour >= 0 and a_hour <= 23
    valid_minute: a_minute >= 0 and a_minute <= 59
    valid_second: a_second >= 0 and a_second <= 59
ensure
    hour_set: hour = a_hour
    minute_set: minute = a_minute
    second_set: second = a_second

-- make_from_seconds
require
    valid_seconds: a_seconds >= 0 and a_seconds < 86400
```

### Access Postconditions
```eiffel
-- hour
ensure
    valid_range: Result >= 0 and Result <= 23

-- minute, second
ensure
    valid_range: Result >= 0 and Result <= 59

-- hour_12
ensure
    valid_range: Result >= 1 and Result <= 12

-- seconds_since_midnight
ensure
    valid_range: Result >= 0 and Result < 86400
```

### Class Invariants
```eiffel
invariant
    internal_time_attached: internal_time /= Void
    valid_hour: hour >= 0 and hour <= 23
    valid_minute: minute >= 0 and minute <= 59
    valid_second: second >= 0 and second <= 59
```

---

## 4. SIMPLE_DATE_TIME Contracts

### Creation
```eiffel
-- make
require
    valid_month: a_month >= 1 and a_month <= 12
    valid_day: a_day >= 1 and a_day <= 31
    valid_hour: a_hour >= 0 and a_hour <= 23
    valid_minute: a_minute >= 0 and a_minute <= 59
    valid_second: a_second >= 0 and a_second <= 59
ensure
    year_set: year = a_year
    month_set: month = a_month
    day_set: day = a_day
    hour_set: hour = a_hour
    minute_set: minute = a_minute
    second_set: second = a_second
```

### Class Invariants
```eiffel
invariant
    internal_datetime_attached: internal_datetime /= Void
```

---

## 5. Contract Design Principles

1. **Component Validation:** All date/time components validated on creation
2. **Non-void Results:** All factory and arithmetic methods guarantee non-void results
3. **Range Guarantees:** Access features document valid ranges via postconditions
4. **Immutable-style:** Arithmetic operations return new instances
5. **Weekday Convention:** ISO 8601 weekday numbering (1=Monday, 7=Sunday)
