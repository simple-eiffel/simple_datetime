# S04-FEATURE-SPECS.md
## simple_datetime - Feature Specifications

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. SIMPLE_DATETIME Facade Features

### 1.1 Current Time Factory

#### now / current_time / current_datetime / timestamp
**Signature:** `: SIMPLE_DATE_TIME`
**Purpose:** Get current local date and time
**Behavior:** Creates new SIMPLE_DATE_TIME with `make_now`

#### utc_now / utc_timestamp / current_utc
**Signature:** `: SIMPLE_DATE_TIME`
**Purpose:** Get current UTC date and time
**Behavior:** Creates new SIMPLE_DATE_TIME with `make_now_utc`, sets is_utc flag

#### today / current_date / todays_date
**Signature:** `: SIMPLE_DATE`
**Purpose:** Get today's date (no time component)

#### tomorrow / yesterday
**Signature:** `: SIMPLE_DATE`
**Purpose:** Get tomorrow's/yesterday's date
**Behavior:** Delegates to `today.plus_days(1)` or `today.minus_days(1)`

### 1.2 Creation Factory

#### date / new_date / make_date / create_date
**Signature:** `(a_year, a_month, a_day: INTEGER): SIMPLE_DATE`
**Validation:** Month 1-12, Day 1-31

#### time / new_time / make_time / create_time
**Signature:** `(a_hour, a_minute, a_second: INTEGER): SIMPLE_TIME`
**Validation:** Hour 0-23, Minute/Second 0-59

#### datetime / new_datetime / make_datetime / create_datetime
**Signature:** `(a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER): SIMPLE_DATE_TIME`
**Validation:** Combined date and time validation

### 1.3 Parsing

#### parse_date / decode_date / date_from_string / string_to_date
**Signature:** `(a_string: STRING): SIMPLE_DATE`
**Supported Formats:**
- `YYYY-MM-DD` (ISO 8601)
- `MM/DD/YYYY` (American)
- `DD.MM.YYYY` (European)
- `YYYYMMDD` (Compact)

#### parse_datetime / parse_iso8601
**Signature:** `(a_string: STRING): SIMPLE_DATE_TIME`
**Supported Formats:**
- `YYYY-MM-DDTHH:MM:SS` (ISO 8601)
- `YYYY-MM-DD HH:MM:SS` (Space separator)
- `YYYY-MM-DDTHH:MM:SSZ` (UTC)
- Timezone offsets stripped

### 1.4 Relative Date Navigation

#### next_monday through next_friday
**Signature:** `: SIMPLE_DATE`
**Behavior:** Returns next occurrence of weekday from today
**Note:** If today is that weekday, returns next week

#### last_monday, last_friday
**Signature:** `: SIMPLE_DATE`
**Behavior:** Returns most recent past occurrence

#### first_of_month / last_of_month / first_of_next_month
**Signature:** `: SIMPLE_DATE`
**Behavior:** Boundary navigation for current month

#### first_of_year / last_of_year
**Signature:** `: SIMPLE_DATE`
**Behavior:** Returns January 1 or December 31 of current year

### 1.5 Age Calculation

#### age_from
**Signature:** `(a_birthdate: SIMPLE_DATE): SIMPLE_AGE`
**Purpose:** Calculate age from birthdate to today
**Validation:** Birthdate must be in past or today

#### age_between
**Signature:** `(a_start, a_end: SIMPLE_DATE): SIMPLE_AGE`
**Purpose:** Calculate duration between two dates
**Validation:** Start must be before or equal to end

### 1.6 Business Day Support

#### add_business_days
**Signature:** `(a_date: SIMPLE_DATE; a_days: INTEGER): SIMPLE_DATE`
**Behavior:** Skips Saturdays and Sundays

#### business_days_between
**Signature:** `(a_start, a_end: SIMPLE_DATE): INTEGER`
**Behavior:** Counts only weekdays between dates

#### is_business_day
**Signature:** `(a_date: SIMPLE_DATE): BOOLEAN`
**Behavior:** True if date is Monday-Friday

#### next_business_day
**Signature:** `(a_date: SIMPLE_DATE): SIMPLE_DATE`
**Behavior:** Returns next weekday (may be same day if already weekday)

### 1.7 Human-Friendly Output

#### time_ago
**Signature:** `(a_datetime: SIMPLE_DATE_TIME): STRING`
**Purpose:** Human-readable past relative time
**Examples:** "just now", "5 minutes ago", "yesterday", "2 weeks ago"

#### time_until
**Signature:** `(a_datetime: SIMPLE_DATE_TIME): STRING`
**Purpose:** Human-readable future relative time
**Examples:** "now", "in 5 minutes", "tomorrow", "in 2 weeks"

---

## 2. SIMPLE_DATE Features

### 2.1 Date Arithmetic

#### plus_days / add_days / days_from_now
**Signature:** `(a_days: INTEGER): SIMPLE_DATE`
**Behavior:** Returns new date, handles month/year rollover

#### plus_months / minus_months
**Signature:** `(a_months: INTEGER): SIMPLE_DATE`
**Behavior:** Day clamped to valid range (Jan 31 + 1 month = Feb 28/29)

#### plus_years
**Signature:** `(a_years: INTEGER): SIMPLE_DATE`
**Behavior:** Feb 29 becomes Feb 28 in non-leap years

### 2.2 Navigation

#### start_of_month / end_of_month
**Signature:** `: SIMPLE_DATE`
**Behavior:** First/last day of same month

#### next_weekday / previous_weekday
**Signature:** `(a_weekday: INTEGER): SIMPLE_DATE`
**Parameters:** Weekday 1-7 (Monday=1, Sunday=7)
**Behavior:** If current day is target, returns +/- 7 days

### 2.3 Output Formats

| Method | Format | Example |
|--------|--------|---------|
| `to_iso8601` | YYYY-MM-DD | 2025-12-07 |
| `to_iso_compact` | YYYYMMDD | 20251207 |
| `to_american` | MM/DD/YYYY | 12/07/2025 |
| `to_european` | DD.MM.YYYY | 07.12.2025 |
| `to_human` | Month D, YYYY | December 7, 2025 |
| `to_human_short` | Mon D, YYYY | Dec 7, 2025 |

---

## 3. SIMPLE_TIME Features

### 3.1 12-Hour Support

#### hour_12
**Signature:** `: INTEGER`
**Range:** 1-12
**Behavior:** Converts 0 -> 12, 13-23 -> 1-11

#### is_am / is_pm
**Signature:** `: BOOLEAN`
**Behavior:** AM if hour < 12, PM if hour >= 12

### 3.2 Period Detection

- `is_morning`: hour < 12
- `is_afternoon`: 12 <= hour < 18
- `is_evening`: hour >= 18
- `is_midnight`: hour=0, minute=0, second=0
- `is_noon`: hour=12, minute=0, second=0

### 3.3 Output Formats

| Method | Format | Example |
|--------|--------|---------|
| `to_iso8601` | HH:MM:SS | 14:30:00 |
| `to_iso_compact` | HHMMSS | 143000 |
| `to_short` | HH:MM | 14:30 |
| `to_12hour` | H:MM AM/PM | 2:30 PM |
| `to_12hour_with_seconds` | H:MM:SS AM/PM | 2:30:00 PM |

---

## 4. SIMPLE_DATE_TIME Features

### 4.1 Human-Friendly Output (Innovative)

#### time_ago
**Thresholds:**
- < 60 seconds: "just now"
- < 60 minutes: "N minutes ago"
- < 24 hours: "N hours ago"
- < 48 hours: "yesterday"
- < 7 days: "N days ago"
- < 30 days: "N weeks ago"
- < 365 days: "N months ago"
- >= 365 days: "N years ago"

#### time_until
**Thresholds:** Same as time_ago with "in N" prefix
- < 60 seconds: "now"
- < 48 hours: "tomorrow"
- Else: "in N [units]"

### 4.2 Timestamp Conversion

#### to_timestamp
**Signature:** `: INTEGER_64`
**Purpose:** Unix timestamp (seconds since 1970-01-01 UTC)

#### make_from_timestamp
**Signature:** `(a_unix_timestamp: INTEGER_64)`
**Purpose:** Create from Unix timestamp
**Note:** Sets is_utc to True
