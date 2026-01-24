# S05-CONSTRAINTS.md
## simple_datetime - Constraints and Limitations

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Date Constraints

### 1.1 Valid Ranges
- **Year:** No explicit range (limited by INTEGER)
- **Month:** 1-12
- **Day:** 1-31 (further constrained by month)
- **Day of Week:** 1-7 (ISO 8601: Monday=1, Sunday=7)

### 1.2 Leap Year Handling
- Correctly handles Feb 29
- `plus_years` converts Feb 29 to Feb 28 in non-leap years
- Leap year detection via Eiffel's DATE class

### 1.3 Month-End Clamping
- `plus_months` clamps day to valid range
- Jan 31 + 1 month = Feb 28 (or 29 in leap year)
- May 31 - 1 month = Apr 30

## 2. Time Constraints

### 2.1 Valid Ranges
- **Hour:** 0-23
- **Minute:** 0-59
- **Second:** 0-59
- **Milliseconds:** Not supported

### 2.2 Wrapping Behavior
- Arithmetic wraps at 24-hour boundary
- `23:00 + 2 hours = 01:00`
- No date rollover from time arithmetic

## 3. Timezone Constraints

### 3.1 Limited Timezone Support
- **Constraint:** Only UTC and local time supported
- **Rationale:** Full timezone requires IANA database
- **Impact:** No "America/New_York" style timezone handling

### 3.2 UTC Marking
- `is_utc` flag indicates UTC time
- No automatic timezone conversion
- Parsing strips timezone offsets

## 4. Parsing Constraints

### 4.1 Supported Date Formats
| Format | Pattern | Example |
|--------|---------|---------|
| ISO 8601 | YYYY-MM-DD | 2025-12-07 |
| American | MM/DD/YYYY | 12/07/2025 |
| European | DD.MM.YYYY | 07.12.2025 |
| Compact | YYYYMMDD | 20251207 |

### 4.2 Unsupported Date Formats
- Natural language ("December 7, 2025")
- Relative ("next Tuesday", "in 3 days")
- Two-digit years (25 vs 2025)
- Ordinal dates (2025-341)

### 4.3 Parsing Failure Behavior
- Invalid date defaults to 1970-01-01
- No exception thrown
- No parsing error indicator

## 5. Business Day Constraints

### 5.1 Weekend Definition
- **Constraint:** Saturday and Sunday only
- **Rationale:** ISO/Western standard
- **Impact:** Not configurable for other calendars

### 5.2 No Holiday Support
- **Constraint:** No holiday calendar integration
- **Impact:** `plus_business_days` skips weekends only
- **Workaround:** Manual holiday checking required

## 6. Duration Constraints

### 6.1 No Mixed Units
- Duration is stored as total seconds
- Display as days/hours/minutes/seconds
- No direct month/year duration (variable lengths)

## 7. Performance Constraints

### 7.1 Immutable-Style Overhead
- Every arithmetic operation creates new object
- Not suitable for microsecond-precision operations
- Recommended for application-level datetime logic

### 7.2 business_days_until Performance
- Iterates day-by-day
- O(n) where n = number of days between dates
- Large ranges may be slow

## 8. Feature Gaps (vs Research Recommendations)

| Feature | Status | Notes |
|---------|--------|-------|
| Immutability | Implemented | New objects returned |
| Fluent API | Implemented | Chainable methods |
| Timezone-aware default | Partial | UTC flag only |
| Business days | Implemented | Weekends only |
| Age calculation | Implemented | SIMPLE_AGE class |
| time_ago | Implemented | Human-friendly output |
| Date ranges | Implemented | With iteration |
| Smart parsing | Partial | Limited formats |
| Natural language parsing | Not implemented | No NLP |
| Recurring events | Not implemented | Out of scope |
| Locale support | Not implemented | English only |
