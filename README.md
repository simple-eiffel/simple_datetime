<p align="center">
  <img src="docs/images/logo.svg" alt="simple_datetime logo" width="400">
</p>

# simple_datetime

**[Documentation](https://simple-eiffel.github.io/simple_datetime/)** | **[GitHub](https://github.com/simple-eiffel/simple_datetime)**

High-level datetime library for Eiffel providing fluent date/time manipulation, age calculations, and date ranges with business day support.

## Overview

`simple_datetime` wraps Eiffel DATE, TIME, and DATE_TIME classes with a simpler API featuring:

- **Multiple output formats** - ISO 8601, American (MM/DD/YYYY), European (DD.MM.YYYY), human-readable
- **Fluent arithmetic** - `date.plus_days(7).plus_months(1)`
- **Business day calculations** - Skip weekends automatically
- **Age calculations** - Years, months, days with legal threshold checks
- **Date ranges** - Iteration, overlap detection, intersection/union
- **Relative time** - "5 minutes ago", "in 2 hours"

Design influenced by:
- **Eiffel Loop** (Finnian Reilly) - EL_DATE_TEXT localization patterns
- **Pylon library** - Multiple format output (to_iso, to_european, to_rfc)
- **ISO8601 library** (Thomas Beale) - Validation before conversion pattern

## API Integration

`simple_datetime` is part of the `simple_*` API hierarchy:

```
FOUNDATION_API (core utilities: json, uuid, base64, validation, datetime, etc.)
       |
SERVICE_API (services: jwt, smtp, sql, cors, cache, websocket, pdf)
       |
APP_API (full application stack)
```

### Using via FOUNDATION_API

If your project uses `simple_foundation_api`, you automatically have access:

```eiffel
class MY_SERVICE
inherit
    FOUNDATION_API
feature
    show_user_age (birthdate: SIMPLE_DATE)
        local
            age: SIMPLE_AGE
        do
            create age.make_from_birthdate (birthdate)
            print (age.to_string)  -- "35 years, 8 months, 22 days"
        end
end
```

### Standalone Installation

1. Clone the repository
2. Set environment variable (one-time setup for all simple_* libraries): `SIMPLE_EIFFEL=D:\prod`
3. Add to your ECF:

```xml
<library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
```

## Quick Start

```eiffel
local
    d: SIMPLE_DATE
    t: SIMPLE_TIME
    dt: SIMPLE_DATE_TIME
do
    -- Dates
    create d.make (2025, 12, 7)
    print (d.to_iso8601)     -- "2025-12-07"
    print (d.to_human)       -- "December 7, 2025"
    print (d.weekday_name)   -- "Sunday"

    -- Times
    create t.make (14, 30, 0)
    print (t.to_12hour)      -- "2:30 PM"

    -- DateTimes
    create dt.make_now
    print (dt.time_ago)      -- "just now"
end
```

## Classes

### SIMPLE_DATE
Date manipulation with multiple output formats.

```eiffel
create d.make (2025, 12, 7)
print (d.to_iso8601)    -- "2025-12-07"
print (d.to_american)   -- "12/07/2025"
print (d.to_european)   -- "07.12.2025"
print (d.to_human)      -- "December 7, 2025"

next_week := d.plus_days (7)
if d.is_weekend then print ("Weekend!") end
```

### SIMPLE_TIME
Time with 12-hour format and period detection.

```eiffel
create t.make (14, 30, 45)
print (t.hour_12)      -- 2
print (t.is_pm)        -- True
print (t.to_12hour)    -- "2:30 PM"
if t.is_afternoon then print ("Good afternoon") end
```

### SIMPLE_DATE_TIME
Combined datetime with relative time output.

```eiffel
create dt.make_now
print (dt.to_iso8601)  -- "2025-12-07T14:30:00"
print (dt.to_human)    -- "December 7, 2025 at 2:30 PM"
print (dt.time_ago)    -- "just now"
```

### SIMPLE_DURATION
Duration with ISO 8601 format.

```eiffel
create d.make (2, 3, 30, 45)  -- 2 days, 3h, 30m, 45s
print (d.to_iso8601)   -- "P2DT3H30M45S"
print (d.to_human)     -- "2 days, 3 hours, 30 minutes, 45 seconds"
```

### SIMPLE_AGE (Innovative!)
Age calculation with legal threshold checks.

```eiffel
create birthdate.make (1990, 3, 15)
create age.make_from_birthdate (birthdate)

print (age.to_string)  -- "35 years, 8 months, 22 days"
print (age.to_short)   -- "35y 8m 22d"

if age.is_adult then print ("18+") end
if age.is_senior then print ("65+") end
if age.is_at_least (21) then print ("Can drink in US") end
```

### SIMPLE_DATE_RANGE (Innovative!)
Date ranges with iteration and business day support.

```eiffel
create range.make_month (2025, 1)
print (range.total_days)      -- 31
print (range.business_days)   -- 23

across range as d loop
    print (d.to_iso8601)
end

if range.overlaps (other_range) then ... end
```

## Business Days

Skip weekends automatically in date calculations.

```eiffel
create d.make (2025, 12, 5)  -- Friday
deadline := d.plus_business_days (3)
print (deadline.to_iso8601)  -- "2025-12-10" (Wednesday)
```

## Testing

46 tests covering all classes:

```bash
ec.exe -batch -config simple_datetime.ecf -target simple_datetime_tests -c_compile
./EIFGENs/simple_datetime_tests/W_code/simple_datetime.exe
```

## License

MIT License - Copyright (c) 2025, Larry Rix
