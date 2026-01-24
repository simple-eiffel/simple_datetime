# S06-BOUNDARIES.md
## simple_datetime - API Boundaries

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Public API Surface

### 1.1 SIMPLE_DATETIME (Facade)

#### Exported to ALL
All features are public. This is the main entry point.

### 1.2 SIMPLE_DATE

#### Exported to ALL
- All creation procedures
- All access features (year, month, day, etc.)
- All status queries
- All comparison features
- All arithmetic features
- All navigation features
- All output features
- All conversion features

#### Exported to SIMPLE_DATE, SIMPLE_DATE_TIME, SIMPLE_AGE, SIMPLE_DATE_RANGE, SIMPLE_DATE_RANGE_CURSOR
- `internal_date: DATE` - Wrapped Eiffel DATE

### 1.3 SIMPLE_TIME

#### Exported to ALL
- All features except internal_time

#### Exported to SIMPLE_TIME, SIMPLE_DATE_TIME
- `internal_time: TIME` - Wrapped Eiffel TIME

### 1.4 SIMPLE_DATE_TIME

#### Exported to ALL
- All features except internal_datetime

#### Exported to SIMPLE_DATE_TIME only
- `internal_datetime: DATE_TIME` - Wrapped Eiffel DATE_TIME

## 2. Conversion Support

### 2.1 Convert Clauses

```eiffel
-- SIMPLE_DATE
convert
    to_date: {DATE}

-- SIMPLE_TIME
convert
    to_time: {TIME}

-- SIMPLE_DATE_TIME
convert
    to_date_time: {DATE_TIME}
```

### 2.2 Interoperability
- All classes can convert to ISE equivalents
- Allows mixing with Eiffel standard library
- No implicit conversion FROM ISE types

## 3. Dependency Boundaries

### 3.1 Internal Dependencies
- SIMPLE_DATETIME uses SIMPLE_DATE, SIMPLE_TIME, SIMPLE_DATE_TIME
- SIMPLE_DATE_TIME uses SIMPLE_DATE, SIMPLE_TIME
- SIMPLE_AGE uses SIMPLE_DATE
- SIMPLE_DATE_RANGE uses SIMPLE_DATE

### 3.2 External Dependencies
- **time** library: DATE, TIME, DATE_TIME, DATE_TIME_DURATION
- **base** library: COMPARABLE, STRING

## 4. Extension Points

### 4.1 Subclassing
- All classes can be inherited
- Internal attributes accessible via restricted export
- Invariants must be maintained

### 4.2 Adding New Formats
- Parsing: Extend `make_from_string`
- Output: Add new `to_*` methods

## 5. Integration Patterns

### 5.1 Basic Usage
```eiffel
-- Using facade
dt: SIMPLE_DATETIME
create dt.make

today := dt.today
next_week := today.plus_days (7)
is_weekend := next_week.is_weekend
```

### 5.2 Parsing and Formatting
```eiffel
-- Parse user input
date := dt.parse_date ("2025-12-07")

-- Format for display
human := date.to_human  -- "December 7, 2025"
iso := date.to_iso8601  -- "2025-12-07"
```

### 5.3 Business Logic
```eiffel
-- Calculate delivery date (5 business days)
ship_date := dt.today
delivery := dt.add_business_days (ship_date, 5)

-- Check if meeting is in past
meeting_time := dt.parse_datetime ("2025-12-07T14:30:00")
if meeting_time.is_past then
    print ("Meeting has passed")
end
```

### 5.4 Age Calculation
```eiffel
-- Calculate user's age
birthdate := dt.parse_date ("1990-05-15")
age := dt.age_from (birthdate)
print ("You are " + age.years.out + " years old")
```

### 5.5 Date Range Iteration
```eiffel
-- Iterate over date range
start_date := dt.date (2025, 1, 1)
end_date := dt.date (2025, 1, 31)
range := dt.date_range (start_date, end_date)

across range as cursor loop
    print (cursor.item.to_iso8601 + "%N")
end
```

### 5.6 Human-Friendly Display
```eiffel
-- Show relative time
post_time := dt.parse_datetime ("2025-12-06T10:30:00")
print ("Posted " + dt.time_ago (post_time))  -- "Posted yesterday"

-- Show upcoming event
event_time := dt.datetime (2025, 12, 25, 9, 0, 0)
print ("Event " + dt.time_until (event_time))  -- "Event in 18 days"
```

## 6. Type Safety

### 6.1 No Nulls
- All factory methods return attached types
- Parsing returns valid (possibly default) dates
- No Void results from public API

### 6.2 Immutable-Style
- Arithmetic returns new objects
- Original values unchanged
- Safe for concurrent access (read-only)
